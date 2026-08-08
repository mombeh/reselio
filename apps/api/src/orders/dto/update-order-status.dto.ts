import { IsEnum } from 'class-validator';

export class UpdateOrderStatusDto {
  @IsEnum([
    'Pending',
    'Confirmed',
    'Preparing',
    'Ready for Pickup',
    'Delivered',
    'Cancelled',
  ])
  status: string;
}
