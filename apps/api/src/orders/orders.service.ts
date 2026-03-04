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
  async updateStatus(orderId: string, status: string, userId: string) {
    const order = await this.orderModel.findOne({ _id: orderId, userId });
    if (!order) {
      throw new Error('Order not found or you are not authorized');
    }
    order.status = status;
    return order.save();
  }
  async getDashboardMetrics(userId: string) {
    const orders = await this.orderModel.find({ userId });

    const totalOrders = orders.length;
    const totalRevenue = orders.reduce((sum, o) => sum + o.sellingPrice, 0);
    const totalProfit = orders.reduce((sum, o) => sum + o.profit, 0);
    const pendingDeliveries = orders.filter(
      (o) => o.status !== 'Delivered',
    ).length;
    const outstandingBalances = orders.reduce(
      (sum, o) => sum + (o.balance || 0),
      0,
    );

    return {
      totalOrders,
      totalRevenue,
      totalProfit,
      pendingDeliveries,
      outstandingBalances,
    };
  }
}
