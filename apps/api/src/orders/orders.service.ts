import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Order, OrderDocument } from './schemas/order.schema';

@Injectable()
export class OrdersService {
  constructor(
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
  ) {}

  async create(orderData: any, userId: string) {
    const balance = orderData.sellingPrice - orderData.advancePaid;
    const profit = orderData.sellingPrice - orderData.costPrice;

    const order = new this.orderModel({
      ...orderData,
      userId,
      balance,
      profit,
    });

    return order.save();
  }
  async findAllByUser(userId: string) {
    return this.orderModel.find({ userId }).sort({ createdAt: -1 });
  }
}
