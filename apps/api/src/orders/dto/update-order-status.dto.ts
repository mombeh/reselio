import { IsEnum } from 'class-validator';

export class UpdateOrderStatusDto {
  @IsEnum([
    'Waiting for Supplier',
    'Supplier Shipped',
    'Received',
    'Sent to Customer',
    'Delivered',
  ])
  status: string;
}
