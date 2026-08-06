import { IsEnum } from 'class-validator';

export class UpdateOrderStatusDto {
  @IsEnum([
    'Pending',
    'Waiting for Supplier',
    'Supplier Shipped',
    'Received',
    'Sent to Customer',
    'Delivered',
    'Cancelled',
  ])
  status: string;
}
