import { ConflictException, Injectable } from '@nestjs/common';
import { CreateDrinkDto } from './dto/create-drink.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Drink } from './entities/drink.entity';
import { FindOneOptions, In, Repository, UpdateResult } from 'typeorm';
import { UpdateDrinkPriceDto } from './dto/update-drink.dto';
import { InternalServerErrorException } from '@nestjs/common';

@Injectable()
export class DrinkService {
  constructor(
    @InjectRepository(Drink)
    private readonly drinkRepository: Repository<Drink>,
  ) {}

  async create(createDrinkDto: CreateDrinkDto) {
    try {
      const drink = this.drinkRepository.create(createDrinkDto);
      console.log(drink);

      return await this.drinkRepository.save(drink);
    } catch (error) {
      console.log(error);

      const { code } = error as { code: string } & Error;
      if (code === '23505') {
        throw new ConflictException('drink alredy exist');
      }
      throw new InternalServerErrorException();
    }
  }

  findAll() {
    return this.drinkRepository.find({
      select: { id: true, name: true, price: true },
    });
  }

  findOne(id: string, options: FindOneOptions<Drink> = {}) {
    return this.drinkRepository.findOne({ where: { id }, ...options });
  }

  findMany(ids: string[]) {
    return this.drinkRepository.find({ where: { id: In(ids) } });
  }

  updatePrice(
    id: string,
    { price }: UpdateDrinkPriceDto,
  ): Promise<UpdateResult> {
    return this.drinkRepository.update(id, { price });
  }

  remove(id: string) {
    return this.drinkRepository.delete(id);
  }
}
