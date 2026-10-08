import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { Order } from './order.schema';

export type OrderItemDocument = OrderItem & Document;

@Schema({ timestamps: true })
export class OrderItem {
  @Prop({ required: true, type: Types.ObjectId, ref: Order.name })
  orderId: Types.ObjectId;

  @Prop({ required: true })
  productId: string;

  @Prop({ required: true, min: 1 })
  quantity: number;

  @Prop({ required: true, min: 0 })
  unitPrice: number;

  @Prop({ required: true, min: 0 })
  totalPrice: number;
}

export const OrderItemSchema = SchemaFactory.createForClass(OrderItem);
