import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { NotificationType } from '../enums/notification-type.enum';

export type NotificationDocument = Notification & Document;

@Schema({ timestamps: true })
export class Notification {
  @Prop({ required: true })
  userId: string;

  @Prop({ required: true, type: String, enum: Object.values(NotificationType) })
  type: NotificationType;

  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  message: string;

  @Prop({ default: false })
  isRead: boolean;

  @Prop()
  referenceId: string;

  @Prop()
  referenceType: string;
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);
