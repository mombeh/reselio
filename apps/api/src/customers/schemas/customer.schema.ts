import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type CustomerDocument = Customer & Document;

@Schema({ timestamps: true })
export class Customer {
  @Prop({ required: true })
  storeId: string;

  @Prop({ required: true })
  fullName: string;

  @Prop({ required: true })
  phoneNumber: string;

  @Prop()
  email: string;

  @Prop()
  address: string;

  @Prop()
  notes: string;

  @Prop({ index: true })
  userId: string;
}

export const CustomerSchema = SchemaFactory.createForClass(Customer);
