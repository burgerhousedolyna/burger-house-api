import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Patch,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { DrinkService } from './drink.service';
import { CreateDrinkDto } from './dto/create-drink.dto';
import { AuthWithBearerToken } from '../../decorators/authWithBearerToken.decorator';
import { RequirePermission } from '../../decorators/requiredPermission.decorator';
import { PermissionsEnum } from '../../enum/permissions.enum';
import { UpdateDrinkPriceDto } from './dto/update-drink.dto';

@AuthWithBearerToken()
@Controller('drink')
export class DrinkController {
  constructor(private readonly drinkService: DrinkService) {}

  @RequirePermission(PermissionsEnum.DRINK_ADD)
  @Post()
  create(@Body() createDrinkDto: CreateDrinkDto) {
    return this.drinkService.create(createDrinkDto);
  }

  @Get()
  findAll() {
    return this.drinkService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.drinkService.findOne(id);
  }

  @RequirePermission(PermissionsEnum.DRINK_UPDATE)
  @Patch('price/:id')
  updatePrice(
    @Param('id') id: string,
    @Body() updatePrice: UpdateDrinkPriceDto,
  ) {
    return this.drinkService.updatePrice(id, updatePrice);
  }

  @RequirePermission(PermissionsEnum.DRINK_DELETE)
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string) {
    await this.drinkService.remove(id);
    return;
  }
}
