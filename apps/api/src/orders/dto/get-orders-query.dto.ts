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
    'Pending',
    'Confirmed',
    'Preparing',
    'Ready for Pickup',
    'Delivered',
    'Cancelled',
  ])
  status?: string;

  @IsOptional()
  @IsString()
  search?: string;
}
