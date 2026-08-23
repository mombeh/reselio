import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Order, OrderDocument } from '../orders/schemas/order.schema';
import { OrderItem, OrderItemDocument } from '../orders/schemas/order-item.schema';
import { Product, ProductDocument } from '../products/schemas/product.schema';
import { Customer, CustomerDocument } from '../customers/schemas/customer.schema';
import { SalesReportQueryDto, SalesPeriod } from './dto/sales-report-query.dto';
import { RevenueReportQueryDto, RevenuePeriod } from './dto/revenue-report-query.dto';

@Injectable()
export class ReportsService {
  constructor(
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
    @InjectModel(OrderItem.name) private orderItemModel: Model<OrderItemDocument>,
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
    @InjectModel(Customer.name) private customerModel: Model<CustomerDocument>,
  ) {}

  async getSalesReport(storeId: string, query: SalesReportQueryDto) {
    const { period = SalesPeriod.TODAY, startDate, endDate } = query;

    let dateFilter: { createdAt?: { $gte: Date; $lte?: Date } };

    const now = new Date();
    switch (period) {
      case SalesPeriod.TODAY:
        const startOfDay = new Date(now);
        startOfDay.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfDay } };
        break;
      case SalesPeriod.WEEK:
        const startOfWeek = new Date(now);
        startOfWeek.setDate(now.getDate() - now.getDay());
        startOfWeek.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfWeek } };
        break;
      case SalesPeriod.MONTH:
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        dateFilter = { createdAt: { $gte: startOfMonth } };
        break;
      case SalesPeriod.CUSTOM:
        if (!startDate || !endDate) {
          throw new NotFoundException(
            'startDate and endDate are required for custom period',
          );
        }
        dateFilter = {
          createdAt: {
            $gte: new Date(startDate),
            $lte: new Date(endDate),
          },
        };
        break;
      default:
        const startOfDayDefault = new Date(now);
        startOfDayDefault.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfDayDefault } };
    }

    const orders = await this.orderModel
      .find({ storeId, ...dateFilter, status: 'Delivered' })
      .populate('customerId', 'fullName phoneNumber');

    const totalOrders = orders.length;
    const totalRevenue = orders.reduce((sum, o) => sum + o.total, 0);
    const totalProfit = orders.reduce((sum, o) => sum + (o.profit || 0), 0);
    const averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    return {
      period,
      startDate: dateFilter.createdAt?.$gte,
      endDate: dateFilter.createdAt?.$lte,
      totalOrders,
      totalRevenue,
      totalProfit,
      averageOrderValue,
    };
  }

  async getProductPerformance(storeId: string) {
    const products = await this.productModel.find({ storeId });

    const productStats = await this.orderItemModel.aggregate([
      {
        $lookup: {
          from: 'orders',
          localField: 'orderId',
          foreignField: '_id',
          as: 'order',
        },
      },
      { $unwind: '$order' },
      { $match: { 'order.storeId': storeId, 'order.status': 'Delivered' } },
      {
        $group: {
          _id: '$productId',
          unitsSold: { $sum: '$quantity' },
          revenue: { $sum: '$totalPrice' },
        },
      },
    ]);

    const statsMap = new Map(
      productStats.map((stat) => [stat._id.toString(), stat]),
    );

    const result = products.map((product) => {
      const stats = statsMap.get(product._id.toString()) || {
        unitsSold: 0,
        revenue: 0,
      };
      return {
        productId: product._id,
        name: product.name,
        unitsSold: stats.unitsSold,
        revenue: stats.revenue,
      };
    });

    return result.sort((a, b) => b.revenue - a.revenue);
  }

  async getCustomerReport(storeId: string) {
    const result = await this.orderModel.aggregate([
      { $match: { storeId, status: 'Delivered' } },
      {
        $lookup: {
          from: 'customers',
          localField: 'customerId',
          foreignField: '_id',
          as: 'customer',
        },
      },
      { $unwind: '$customer' },
      {
        $group: {
          _id: '$customerId',
          customerName: { $first: '$customer.fullName' },
          totalOrders: { $sum: 1 },
          totalSpent: { $sum: '$total' },
        },
      },
      { $sort: { totalSpent: -1 } },
    ]);

    return result.map((item) => ({
      customerId: item._id,
      customerName: item.customerName,
      totalOrders: item.totalOrders,
      totalSpent: item.totalSpent,
    }));
  }

  async getRevenueTrend(storeId: string, query: RevenueReportQueryDto) {
    const { period = RevenuePeriod.MONTH, startDate, endDate } = query;

    let dateFilter: { createdAt?: { $gte: Date; $lte?: Date } };
    let dateFormat: string;

    const now = new Date();
    switch (period) {
      case RevenuePeriod.WEEK:
        const startOfWeek = new Date(now);
        startOfWeek.setDate(now.getDate() - now.getDay());
        startOfWeek.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfWeek } };
        dateFormat = '%Y-%m-%d';
        break;
      case RevenuePeriod.MONTH:
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        dateFilter = { createdAt: { $gte: startOfMonth } };
        dateFormat = '%Y-%m-%d';
        break;
      case RevenuePeriod.YEAR:
        const startOfYear = new Date(now.getFullYear(), 0, 1);
        dateFilter = { createdAt: { $gte: startOfYear } };
        dateFormat = '%Y-%m';
        break;
      default:
        const startOfWeekDefault = new Date(now);
        startOfWeekDefault.setDate(now.getDate() - now.getDay());
        startOfWeekDefault.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfWeekDefault } };
        dateFormat = '%Y-%m-%d';
    }

    if (startDate && endDate) {
      dateFilter = {
        createdAt: {
          $gte: new Date(startDate),
          $lte: new Date(endDate),
        },
      };
    }

    const result = await this.orderModel.aggregate([
      { $match: { storeId, status: 'Delivered', ...dateFilter } },
      {
        $group: {
          _id: {
            $dateToString: { format: dateFormat, date: '$createdAt' },
          },
          revenue: { $sum: '$total' },
        },
      },
      { $sort: { '_id': 1 } },
    ]);

    return result.map((item) => ({
      date: item._id,
      revenue: item.revenue,
    }));
  }

  async getPlatformSalesReport(query: SalesReportQueryDto) {
    const { period = SalesPeriod.TODAY, startDate, endDate } = query;

    let dateFilter: { createdAt?: { $gte: Date; $lte?: Date } };

    const now = new Date();
    switch (period) {
      case SalesPeriod.TODAY:
        const startOfDay = new Date(now);
        startOfDay.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfDay } };
        break;
      case SalesPeriod.WEEK:
        const startOfWeek = new Date(now);
        startOfWeek.setDate(now.getDate() - now.getDay());
        startOfWeek.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfWeek } };
        break;
      case SalesPeriod.MONTH:
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        dateFilter = { createdAt: { $gte: startOfMonth } };
        break;
      case SalesPeriod.CUSTOM:
        if (!startDate || !endDate) {
          throw new NotFoundException(
            'startDate and endDate are required for custom period',
          );
        }
        dateFilter = {
          createdAt: {
            $gte: new Date(startDate),
            $lte: new Date(endDate),
          },
        };
        break;
      default:
        const startOfDayDefault = new Date(now);
        startOfDayDefault.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfDayDefault } };
    }

    const orders = await this.orderModel
      .find({ ...dateFilter, status: 'Delivered' })
      .populate('customerId', 'fullName phoneNumber');

    const totalOrders = orders.length;
    const totalRevenue = orders.reduce((sum, o) => sum + o.total, 0);
    const totalProfit = orders.reduce((sum, o) => sum + (o.profit || 0), 0);
    const averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    return {
      period,
      startDate: dateFilter.createdAt?.$gte,
      endDate: dateFilter.createdAt?.$lte,
      totalOrders,
      totalRevenue,
      totalProfit,
      averageOrderValue,
    };
  }

  async getPlatformRevenueTrend(query: RevenueReportQueryDto) {
    const { period = RevenuePeriod.MONTH, startDate, endDate } = query;

    let dateFilter: { createdAt?: { $gte: Date; $lte?: Date } };
    let dateFormat: string;

    const now = new Date();
    switch (period) {
      case RevenuePeriod.WEEK:
        const startOfWeek = new Date(now);
        startOfWeek.setDate(now.getDate() - now.getDay());
        startOfWeek.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfWeek } };
        dateFormat = '%Y-%m-%d';
        break;
      case RevenuePeriod.MONTH:
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        dateFilter = { createdAt: { $gte: startOfMonth } };
        dateFormat = '%Y-%m-%d';
        break;
      case RevenuePeriod.YEAR:
        const startOfYear = new Date(now.getFullYear(), 0, 1);
        dateFilter = { createdAt: { $gte: startOfYear } };
        dateFormat = '%Y-%m';
        break;
      default:
        const startOfWeekDefault = new Date(now);
        startOfWeekDefault.setDate(now.getDate() - now.getDay());
        startOfWeekDefault.setHours(0, 0, 0, 0);
        dateFilter = { createdAt: { $gte: startOfWeekDefault } };
        dateFormat = '%Y-%m-%d';
    }

    if (startDate && endDate) {
      dateFilter = {
        createdAt: {
          $gte: new Date(startDate),
          $lte: new Date(endDate),
        },
      };
    }

    const result = await this.orderModel.aggregate([
      { $match: { status: 'Delivered', ...dateFilter } },
      {
        $group: {
          _id: {
            $dateToString: { format: dateFormat, date: '$createdAt' },
          },
          revenue: { $sum: '$total' },
        },
      },
      { $sort: { '_id': 1 } },
    ]);

    return result.map((item) => ({
      date: item._id,
      revenue: item.revenue,
    }));
  }

  async getPlatformProductPerformance() {
    const products = await this.productModel.find({});

    const productStats = await this.orderItemModel.aggregate([
      {
        $lookup: {
          from: 'orders',
          localField: 'orderId',
          foreignField: '_id',
          as: 'order',
        },
      },
      { $unwind: '$order' },
      { $match: { 'order.status': 'Delivered' } },
      {
        $group: {
          _id: '$productId',
          unitsSold: { $sum: '$quantity' },
          revenue: { $sum: '$totalPrice' },
        },
      },
    ]);

    const statsMap = new Map(
      productStats.map((stat) => [stat._id.toString(), stat]),
    );

    const result = products.map((product) => {
      const stats = statsMap.get(product._id.toString()) || {
        unitsSold: 0,
        revenue: 0,
      };
      return {
        productId: product._id,
        name: product.name,
        unitsSold: stats.unitsSold,
        revenue: stats.revenue,
      };
    });

    return result.sort((a, b) => b.revenue - a.revenue);
  }

  async getPlatformCustomerReport() {
    const result = await this.orderModel.aggregate([
      { $match: { status: 'Delivered' } },
      {
        $lookup: {
          from: 'customers',
          localField: 'customerId',
          foreignField: '_id',
          as: 'customer',
        },
      },
      { $unwind: '$customer' },
      {
        $group: {
          _id: '$customerId',
          customerName: { $first: '$customer.fullName' },
          totalOrders: { $sum: 1 },
          totalSpent: { $sum: '$total' },
        },
      },
      { $sort: { totalSpent: -1 } },
    ]);

    return result.map((item) => ({
      customerId: item._id,
      customerName: item.customerName,
      totalOrders: item.totalOrders,
      totalSpent: item.totalSpent,
    }));
  }
}
