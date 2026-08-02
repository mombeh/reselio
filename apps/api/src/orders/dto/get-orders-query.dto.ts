import { IsOptional, IsNumberString, IsEnum, IsString } from 'class-validator';

export class GetOrdersQueryDto {
  @IsOptional()
  @IsNumberString()
  page?: string;

  @IsOptional()
  @IsNumberString()
  limit?: string;

  @IsOptional()
  @IsEnum([
    'Waiting for Supplier',
    'Supplier Shipped',
    'Received',
    'Sent to Customer',
    'Delivered',
  ])
  status?: string;

  @IsOptional()
  @IsString()
  search?: string;
}
