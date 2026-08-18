import { IsString, IsOptional, IsNumber, IsArray, MinLength } from 'class-validator';

export class CreateOrderDto {
  @IsString()
  @IsOptional()
  customerId?: string;

  items: { productId: string; quantity: number }[];

  @IsNumber()
  @IsOptional()
  advancePaid?: number;
}
