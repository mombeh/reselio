import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Parser } from 'json2csv';
import { Order, OrderDocument } from './schemas/order.schema';
import { Customer, CustomerDocument } from './schemas/customer.schema';

@Injectable()
export class OrdersService {
  constructor(
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
    @InjectModel(Customer.name) private customerModel: Model<CustomerDocument>,
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
  async findAllByUser(userId: string, query: any) {
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 10;
    const skip = (page - 1) * limit;

    const filter: any = { userId };

    if (query.status) {
      filter.status = query.status;
    }

    if (query.search) {
      filter.$or = [
        { customerName: { $regex: query.search, $options: 'i' } },
        { phone: { $regex: query.search, $options: 'i' } },
        { productName: { $regex: query.search, $options: 'i' } },
      ];
    }

    const total = await this.orderModel.countDocuments(filter);

    const orders = await this.orderModel
      .find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    return {
      data: orders,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
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
  async getCustomersSummary(userId: string) {
    return this.orderModel.aggregate([
      { $match: { userId } },

      {
        $group: {
          _id: '$phone',
          customerName: { $first: '$customerName' },
          phone: { $first: '$phone' },
          totalOrders: { $sum: 1 },
          totalSpent: { $sum: '$sellingPrice' },
          totalOutstandingBalance: { $sum: '$balance' },
          deliveredOrders: {
            $sum: {
              $cond: [{ $eq: ['$status', 'Delivered'] }, 1, 0],
            },
          },
        },
      },

      { $sort: { totalSpent: -1 } },
    ]);
  }
  async getMonthlyAnalytics(userId: string) {
    return this.orderModel.aggregate([
      { $match: { userId } },

      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
          },
          totalRevenue: { $sum: '$sellingPrice' },
          totalProfit: { $sum: '$profit' },
          totalOrders: { $sum: 1 },
        },
      },

      {
        $sort: {
          '_id.year': 1,
          '_id.month': 1,
        },
      },
    ]);
  }

  async getStatusBreakdown(userId: string) {
    return this.orderModel.aggregate([
      { $match: { userId } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalRevenue: { $sum: '$sellingPrice' },
          totalProfit: { $sum: '$profit' },
        },
      },
    ]);
  }

  async getTopProducts(userId: string, limit: number = 10) {
    return this.orderModel.aggregate([
      { $match: { userId } },
      {
        $group: {
          _id: '$productName',
          totalOrders: { $sum: 1 },
          totalRevenue: { $sum: '$sellingPrice' },
          totalProfit: { $sum: '$profit' },
        },
      },
      { $sort: { totalRevenue: -1 } },
      { $limit: limit },
    ]);
  }

  async getDailySales(userId: string, days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return this.orderModel.aggregate([
      {
        $match: {
          userId,
          createdAt: { $gte: startDate },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          totalOrders: { $sum: 1 },
          totalRevenue: { $sum: '$sellingPrice' },
          totalProfit: { $sum: '$profit' },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]);
  }

  async getYearlyAnalytics(userId: string) {
    return this.orderModel.aggregate([
      { $match: { userId } },
      {
        $group: {
          _id: { $year: '$createdAt' },
          totalRevenue: { $sum: '$sellingPrice' },
          totalProfit: { $sum: '$profit' },
          totalOrders: { $sum: 1 },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]);
  }

  async exportOrders(userId: string): Promise<string> {
    const orders = await this.findAllByUser(userId, {});

    if (orders.data.length === 0) {
      return '';
    }

    const fields = [
      'customerName',
      'phone',
      'productName',
      'size',
      'color',
      'costPrice',
      'sellingPrice',
      'balance',
      'profit',
      'status',
      'createdAt',
    ];

    const parser = new Parser({ fields });
    return parser.parse(orders.data);
  }

  // Customer methods
  async createCustomer(customerData: any, userId: string) {
    const customer = new this.customerModel({
      ...customerData,
      userId,
    });
    return customer.save();
  }

  async findAllCustomers(userId: string) {
    return this.customerModel.find({ userId }).sort({ createdAt: -1 });
  }

  async findCustomerById(customerId: string, userId: string) {
    return this.customerModel.findOne({ _id: customerId, userId });
  }

  async updateCustomer(customerId: string, customerData: any, userId: string) {
    const customer = await this.customerModel.findOne({
      _id: customerId,
      userId,
    });
    if (!customer) {
      throw new Error('Customer not found or you are not authorized');
    }
    Object.assign(customer, customerData);
    return customer.save();
  }

  async deleteCustomer(customerId: string, userId: string) {
    const customer = await this.customerModel.findOne({
      _id: customerId,
      userId,
    });
    if (!customer) {
      throw new Error('Customer not found or you are not authorized');
    }
    return customer.deleteOne();
  }
}
