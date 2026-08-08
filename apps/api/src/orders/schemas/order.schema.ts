import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type OrderDocument = Order & Document;

@Schema({ timestamps: true })
export class Order {
  @Prop({ required: true })
  storeId: string;

  @Prop({ required: true })
  customerId: string;

  @Prop({ required: true, unique: true })
  orderNumber: string;

  @Prop({
    enum: [
      'Pending',
      'Confirmed',
      'Preparing',
      'Ready for Pickup',
      'Delivered',
      'Cancelled',
    ],
    default: 'Pending',
  })
  status: string;

  @Prop({ required: true, min: 0, default: 0 })
  subtotal: number;

  @Prop({ required: true, min: 0, default: 0 })
  total: number;

  @Prop({ default: 0 })
  advancePaid: number;

  @Prop()
  balance: number;

  @Prop()
  profit: number;
}

export const OrderSchema = SchemaFactory.createForClass(Order);
