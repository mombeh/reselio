import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Notification, NotificationDocument } from './schemas/notification.schema';
import { NotificationType } from './enums/notification-type.enum';

export const LOW_STOCK_THRESHOLD = 5;

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(Notification.name) private notificationModel: Model<NotificationDocument>,
  ) {}

  async create(userId: string, data: {
    type: NotificationType;
    title: string;
    message: string;
    referenceId?: string;
    referenceType?: string;
  }) {
    const notification = new this.notificationModel({
      userId,
      type: data.type,
      title: data.title,
      message: data.message,
      referenceId: data.referenceId,
      referenceType: data.referenceType,
    });
    return notification.save();
  }

  async findAllByUser(userId: string) {
    return this.notificationModel.find({ userId }).sort({ createdAt: -1 });
  }

  async findOne(id: string, userId: string) {
    const notification = await this.notificationModel.findOne({ _id: id, userId });
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }
    return notification;
  }

  async markAsRead(id: string, userId: string) {
    const notification = await this.notificationModel.findOneAndUpdate(
      { _id: id, userId },
      { isRead: true },
      { new: true },
    );
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }
    return notification;
  }

  async markAllAsRead(userId: string) {
    return this.notificationModel.updateMany({ userId, isRead: false }, { isRead: true });
  }

  async hasUnreadLowStockNotification(userId: string, productId: string): Promise<boolean> {
    const notification = await this.notificationModel.findOne({
      userId,
      type: NotificationType.LOW_STOCK,
      referenceId: productId,
      referenceType: 'product',
      isRead: false,
    });
    return !!notification;
  }

  async createLowStockNotification(userId: string, productId: string, productName: string, currentStock: number) {
    const existingUnread = await this.hasUnreadLowStockNotification(userId, productId);
    if (existingUnread) {
      return null;
    }

    return this.create(userId, {
      type: NotificationType.LOW_STOCK,
      title: 'Low Stock Alert',
      message: `Product "${productName}" is running low on stock. Current stock: ${currentStock}`,
      referenceId: productId,
      referenceType: 'product',
    });
  }
}
