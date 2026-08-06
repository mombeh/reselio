import { IsString, IsNotEmpty, IsNumber, IsArray, Min, IsOptional } from 'class-validator';

export class CreateOrderItemDto {
  @IsString()
  @IsNotEmpty({ message: 'Product ID is required' })
  productId: string;

  @IsNumber()
  @Min(1, { message: 'Quantity must be at least 1' })
  quantity: number;
}

export class CreateOrderDto {
  @IsString()
  @IsNotEmpty({ message: 'Customer ID is required' })
  customerId: string;

  @IsArray()
  @IsOptional()
  items?: CreateOrderItemDto[];

  @IsNumber()
  @IsOptional()
  advancePaid?: number;
}
