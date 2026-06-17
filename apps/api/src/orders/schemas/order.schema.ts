import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type OrderDocument = Order & Document;

@Schema({ timestamps: true })
export class Order {
  @Prop({ required: true })
  userId: string;

  @Prop({ required: true })
  customerName: string;

  @Prop({ required: true })
  phone: string;

  @Prop({ required: true })
  productName: string;

  @Prop()
  size: string;

  @Prop()
  color: string;

  @Prop({ required: true })
  costPrice: number;

  @Prop({ required: true })
  sellingPrice: number;

  @Prop({ default: 0 })
  advancePaid: number;

  @Prop()
  balance: number;

  @Prop()
  profit: number;

  @Prop({
    enum: [
      'Waiting for Supplier',
      'Supplier Shipped',
      'Received',
      'Sent to Customer',
      'Delivered',
    ],
    default: 'Waiting for Supplier',
  })
  status: string;
}

export const OrderSchema = SchemaFactory.createForClass(Order);
