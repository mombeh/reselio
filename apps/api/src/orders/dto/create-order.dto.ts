import { IsString, IsOptional, IsNumber, IsArray, MinLength } from 'class-validator';

export class CreateOrderDto {
  @IsString()
  @IsOptional()
  customerId?: string;

  @IsArray()
  @MinLength(1, { message: 'Order must contain at least one item' })
  items: { productId: string; quantity: number }[];

  @IsNumber()
  @IsOptional()
  advancePaid?: number;
}
