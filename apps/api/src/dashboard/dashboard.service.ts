import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Order, OrderDocument } from '../orders/schemas/order.schema';
import {
  OrderItem,
  OrderItemDocument,
} from '../orders/schemas/order-item.schema';
import { Product, ProductDocument } from '../products/schemas/product.schema';
import {
  Customer,
  CustomerDocument,
} from '../customers/schemas/customer.schema';
import { User, UserDocument } from '../users/schemas/user.schema';
import { Role } from '../auth/enums/role.enum';

@Injectable()
export class DashboardService {
  constructor(
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
    @InjectModel(OrderItem.name)
    private orderItemModel: Model<OrderItemDocument>,
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
    @InjectModel(Customer.name) private customerModel: Model<CustomerDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  async getDashboard(storeId: string) {
    const [
      totalProducts,
      totalCustomers,
      totalOrders,
      pendingOrders,
      completedOrders,
      todayRevenue,
      monthlyRevenue,
      recentOrders,
      topProducts,
    ] = await Promise.all([
      this.productModel.countDocuments({ storeId }),
      this.customerModel.countDocuments({ storeId }),
      this.orderModel.countDocuments({ storeId }),
      this.orderModel.countDocuments({ storeId, status: 'Pending' }),
      this.orderModel.countDocuments({
        storeId,
        status: 'Delivered',
      }),
      this.getTodayRevenue(storeId),
      this.getMonthlyRevenue(storeId),
      this.getRecentOrders(storeId),
      this.getTopProducts(storeId),
    ]);

    return {
      totalProducts,
      totalCustomers,
      totalOrders,
      pendingOrders,
      completedOrders,
      todayRevenue,
      monthlyRevenue,
      recentOrders,
      topProducts,
    };
  }

  private async getTodayRevenue(storeId: string): Promise<number> {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const result = await this.orderModel.aggregate([
      {
        $match: {
          storeId,
          status: { $ne: 'Cancelled' },
          createdAt: { $gte: startOfDay },
        },
      },
      {
        $group: {
          _id: null,
          revenue: { $sum: '$total' },
        },
      },
    ]);

    return result[0]?.revenue || 0;
  }

  private async getMonthlyRevenue(storeId: string): Promise<number> {
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);

    const result = await this.orderModel.aggregate([
      {
        $match: {
          storeId,
          status: { $ne: 'Cancelled' },
          createdAt: { $gte: startOfMonth },
        },
      },
      {
        $group: {
          _id: null,
          revenue: { $sum: '$total' },
        },
      },
    ]);

    return result[0]?.revenue || 0;
  }

  private async getRecentOrders(storeId: string) {
    return this.orderModel
      .find({ storeId })
      .populate('customerId', 'fullName phoneNumber')
      .sort({ createdAt: -1 })
      .limit(5);
  }

  private async getTopProducts(storeId: string) {
    return this.orderItemModel.aggregate([
      {
        $lookup: {
          from: 'orders',
          localField: 'orderId',
          foreignField: '_id',
          as: 'order',
        },
      },
      { $unwind: '$order' },
      {
        $match: {
          'order.storeId': storeId,
          'order.status': { $ne: 'Cancelled' },
        },
      },
      {
        $lookup: {
          from: 'products',
          localField: 'productId',
          foreignField: '_id',
          as: 'product',
        },
      },
      { $unwind: '$product' },
      {
        $group: {
          _id: '$product.name',
          totalOrders: { $sum: '$quantity' },
          totalRevenue: { $sum: '$totalPrice' },
          imageUrl: { $first: '$product.imageUrl' },
        },
      },
      { $sort: { totalRevenue: -1 } },
      { $limit: 5 },
    ]);
  }

  async getAdminDashboard() {
    const [
      totalSellers,
      totalCustomers,
      totalProducts,
      totalOrders,
      pendingOrders,
      totalRevenue,
      activeUsers,
    ] = await Promise.all([
      this.userModel.countDocuments({ role: Role.Client }),
      this.customerModel.countDocuments(),
      this.productModel.countDocuments(),
      this.orderModel.countDocuments(),
      this.orderModel.countDocuments({ status: 'Pending' }),
      this.getTotalRevenue(),
      this.userModel.countDocuments({ isActive: true }),
    ]);

    return {
      totalSellers,
      totalCustomers,
      totalProducts,
      totalOrders,
      pendingOrders,
      totalRevenue,
      activeUsers,
    };
  }

  private async getTotalRevenue(): Promise<number> {
    const result = await this.orderModel.aggregate([
      {
        $match: {
          status: { $ne: 'Cancelled' },
        },
      },
      {
        $group: {
          _id: null,
          revenue: { $sum: '$total' },
        },
      },
    ]);

    return result[0]?.revenue || 0;
  }
}
