import { IsString, IsNotEmpty, IsArray, ValidateNested, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';

export class GuestInfoDto {
  @IsString()
  @IsNotEmpty()
  fullName: string;

  @IsString()
  @IsNotEmpty()
  phoneNumber: string;

  @IsString()
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  notes?: string;
}

export class GuestOrderItemDto {
  @IsString()
  @IsNotEmpty()
  productId: string;

  @IsNotEmpty()
  quantity: number;
}

export class CreateGuestOrderDto {
  @IsString()
  @IsNotEmpty()
  storeId: string;

  @ValidateNested()
  @Type(() => GuestInfoDto)
  guest: GuestInfoDto;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => GuestOrderItemDto)
  items: GuestOrderItemDto[];
}
