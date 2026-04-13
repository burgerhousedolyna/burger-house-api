import { ApiProperty } from '@nestjs/swagger';
import { GeneralPropertyDecoratorMaker } from '../../../utils/propertyDecoratorApplier';
import {
  IsBoolean,
  IsEmail,
  IsOptional,
  IsString,
  IsUrl,
  Length,
} from 'class-validator';

const GeneralStringDecorator = GeneralPropertyDecoratorMaker(
  ApiProperty(),
  IsOptional(),
  IsString(),
);

export class CreateAboutDto {
  @GeneralStringDecorator()
  @IsUrl()
  facebook?: string | null;
  @GeneralStringDecorator()
  @IsUrl()
  instagram?: string | null;
  @GeneralStringDecorator()
  @IsEmail()
  email?: string | null;
  @GeneralStringDecorator()
  @Length(9, 9)
  phone?: string | null;
  @GeneralStringDecorator()
  placeDescription?: string | null;
  @GeneralStringDecorator()
  placeAddress?: string | null;
  @ApiProperty({ required: false })
  @IsOptional()
  @IsBoolean()
  deliveryOn?: boolean;
}
