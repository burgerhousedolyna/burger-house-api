import { BadRequestException, Injectable } from '@nestjs/common';
import { Repository } from 'typeorm';
import { ClientMenu } from './entities/clientMenu.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { calculatePaginationData } from '../utils/calculatePaginationParams.utils';
import { OrdersService } from '../modules/orders/orders.service';
import { CreateOrderDto } from '../modules/orders/dto/create-order.dto';
import { CountPriceDto } from './dto/countPrice.dt';
import { MenuService } from '../admin/menu/menu.service';
import { totalPriceCalculator } from '../utils/totalPriceCalculator';
import { AboutService } from '../admin/about/about.service';
import { PriceMath } from '../utils/mathWithPrices';
import { GoogleMapsService } from '../modules/google-maps/google-maps.service';
import { TelegrabBotService } from '../services/TelegramBot.service';

@Injectable()
export class ClientService {
  constructor(
    @InjectRepository(ClientMenu)
    private readonly clientMenu: Repository<ClientMenu>,
    private readonly menuService: MenuService,
    private readonly orderService: OrdersService,
    private readonly aboutService: AboutService,
    private readonly gooleMapsService: GoogleMapsService,
    // private readonly ordersGateway: OrdersGateway,
    private readonly telegramBotService: TelegrabBotService,
  ) {}

  async findAll(page: number, take: number, category?: string) {
    const skip = (page - 1) * take;
    const where = {
      onboard: true,
      ...(!category
        ? {}
        : {
            categories: { id: category },
          }),
    };

    const [totalItems, items] = await Promise.all([
      this.clientMenu.count({
        where,
      }),
      this.clientMenu.find({
        where,
        select: {
          id: true,
          title: true,
          subtitle: true,
          price: true,
          image_medium: true,
          categories: false,
        },
        order: {
          title: 'ASC',
          subtitle: 'asc',
        },
        skip,
        take,
      }),
    ]);

    const paginatioData = calculatePaginationData(totalItems, page, take);
    if (paginatioData.totalItems === 0) return { items, ...paginatioData };
    if (paginatioData.page > paginatioData.totalPages)
      throw new BadRequestException(`page ${page} not exist`);

    return { items, ...paginatioData };
  }

  async findOne(id: string) {
    const item = await this.clientMenu.findOne({
      where: { id },
      relations: { categories: true, dishes: true, drinks: true },
    });

    return item;
  }

  async getAbout() {
    const dateNow = new Date();
    const year = dateNow.getFullYear();
    const month = String(dateNow.getMonth() + 1).padStart(2, '0');
    const day = String(dateNow.getDate()).padStart(2, '0');
    const formattedDate = `${year}-${month}-${day}`;

    const [aboutData, openningHours, brakeTimes] = await Promise.all([
      this.aboutService.findOne(),
      this.aboutService.getOpeningHours(),
      this.aboutService.getBrakeTimes(formattedDate),
    ]);
    return { ...aboutData, openningHours, brakeTimes };
  }

  async newOrder(createOrderDto: CreateOrderDto) {
    const { total, delivery } = await this.totalPrice(
      !createOrderDto.delivery
        ? {
            items: [...createOrderDto.selections],
            isDelivery: createOrderDto.delivery,
          }
        : {
            items: [...createOrderDto.selections],
            isDelivery: createOrderDto.delivery,
            distance: createOrderDto.distance as number,
            address: createOrderDto.address as string,
          },
    );

    createOrderDto.amount = total;
    createOrderDto.deliveryPrice = delivery;
    const [order] = await Promise.all([
      this.orderService.create(createOrderDto),
      this.telegramBotService.sendMessage(
        JSON.stringify({
          status: 'очікує',
          createdAt: Date.now(),
          ...(createOrderDto.delivery
            ? { адреса: createOrderDto.address }
            : { адреса: 'в закладі' }),
        }),
      ),
    ]);

    return {
      status: order.status,
      id: order.id,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    };
  }

  async totalPrice({
    items,
    isDelivery,
    address,
    distance,
    secretToken,
  }: CountPriceDto) {
    if (isDelivery && secretToken && address) {
      distance = (
        await this.gooleMapsService
          .getDistanceMatrix(address, secretToken)
          .catch((err) => {
            console.log(err);
            return { distanceMeters: undefined };
          })
      ).distanceMeters;
    }

    const ids: string[] = [];
    const quantityObj = items.reduce(
      (acc, item) => {
        acc[item.id] = item.quantity;
        ids.push(item.id);
        return acc;
      },
      {} as { [key: string]: number },
    );
    const [menuItems, deliveryPrices] = await Promise.all([
      this.menuService.findByIds(ids, ['price']),
      ...(!isDelivery ? [] : [this.aboutService.getDeliveryPrices()]),
    ]);

    const subTotal = totalPriceCalculator(menuItems, quantityObj);
    const discont = 0;
    const deliveryDistance = !isDelivery
      ? 0
      : distance || deliveryPrices[0].distance;

    const outOfDistance = !isDelivery
      ? false
      : !distance ||
        distance > deliveryPrices[deliveryPrices.length - 1].distance;
    let tmpDistance = 0;

    const delivery = !isDelivery
      ? 0
      : deliveryPrices.find((option) => {
          if (
            !(
              (deliveryDistance > tmpDistance &&
                deliveryDistance < option.distance) ||
              option.distance === tmpDistance
            )
          )
            return false;

          if (subTotal < option.minOrder) return true;

          tmpDistance = option.distance;
          return false;
        })?.deliveryPrice || 0;

    const priceWithDeivery = PriceMath.add(subTotal, delivery);
    const total = PriceMath.minus(priceWithDeivery, discont);

    return { total, discont, delivery, subTotal, outOfDistance, distance };
  }
}
