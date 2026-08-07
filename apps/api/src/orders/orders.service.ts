import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Parser } from 'json2csv';
import { Order, OrderDocument } from './schemas/order.schema';
import { OrderItem, OrderItemDocument } from './schemas/order-item.schema';
import { Customer, CustomerDocument } from './schemas/customer.schema';
import { Product, ProductDocument } from '../products/schemas/product.schema';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';

@Injectable()
export class OrdersService {
  constructor(
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
    @InjectModel(OrderItem.name) private orderItemModel: Model<OrderItemDocument>,
    @InjectModel(Customer.name) private customerModel: Model<CustomerDocument>,
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
  ) {}

  private generateOrderNumber(): string {
    const timestamp = Date.now().toString(36).toUpperCase();
    const random = Math.random().toString(36).substr(2, 4).toUpperCase();
    return `ORD-${timestamp}-${random}`;
  }

  async create(storeId: string, createOrderDto: CreateOrderDto) {
    const { customerId, items = [], advancePaid = 0 } = createOrderDto;

    const customer = await this.customerModel.findOne({
      _id: customerId,
      storeId,
    });
    if (!customer) {
      throw new NotFoundException('Customer not found in your store');
    }

    if (items.length === 0) {
      throw new ConflictException('Order must contain at least one item');
    }

    let subtotal = 0;
    let totalCost = 0;
    const orderItems: any[] = [];

    for (const item of items) {
      const product = await this.productModel.findOne({
        _id: item.productId,
        storeId,
      });
      if (!product) {
        throw new NotFoundException(`Product ${item.productId} not found`);
      }

      if (product.quantity < item.quantity) {
        throw new ConflictException(
          `Insufficient stock for ${product.name}. Available: ${product.quantity}`,
        );
      }

      const itemTotal = item.quantity * product.price;
      const itemCost = item.quantity * (product.costPrice || 0);
      subtotal += itemTotal;
      totalCost += itemCost;

      orderItems.push({
        productId: item.productId,
        quantity: item.quantity,
        unitPrice: product.price,
        totalPrice: itemTotal,
      });
    }

    const total = subtotal;
    const profit = total - totalCost;
    const balance = total - advancePaid;
    const orderNumber = this.generateOrderNumber();

    const order = new this.orderModel({
      storeId,
      customerId,
      orderNumber,
      status: 'Pending',
      subtotal,
      total,
      advancePaid,
      balance,
      profit,
    });

    const savedOrder = await order.save();

    for (const item of orderItems) {
      const orderItem = new this.orderItemModel({
        ...item,
        orderId: savedOrder._id,
      });
      await orderItem.save();

      await this.productModel.findByIdAndUpdate(item.productId, {
        $inc: { quantity: -item.quantity },
      });
    }

    return savedOrder.populate([
      { path: 'customerId', model: Customer.name },
      {
        path: 'orderItems',
        match: { orderId: savedOrder._id },
        model: OrderItem.name,
      },
    ]);
  }

  async findAllByStore(storeId: string, query: any) {
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 10;
    const skip = (page - 1) * limit;

    const filter: any = { storeId };

    if (query.status) {
      filter.status = query.status;
    }

    if (query.search) {
      filter.$or = [
        { orderNumber: { $regex: query.search, $options: 'i' } },
      ];
    }

    const total = await this.orderModel.countDocuments(filter);

    const orders = await this.orderModel
      .find(filter)
      .populate('customerId', 'fullName phoneNumber email')
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

  async findOne(id: string, storeId: string) {
    const order = await this.orderModel.findOne({ _id: id, storeId }).populate(
      'customerId',
      'fullName phoneNumber email address',
    );

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    const orderItems = await this.orderItemModel
      .find({ orderId: id })
      .populate('productId', 'name price imageUrl');

    return { ...order.toObject(), orderItems };
  }

  async updateStatus(id: string, storeId: string, status: string) {
    const order = await this.orderModel.findOneAndUpdate(
      { _id: id, storeId },
      { status },
      { new: true },
    );
    if (!order) {
      throw new NotFoundException('Order not found');
    }
    return order;
  }

  async cancelOrder(id: string, storeId: string) {
    const order = await this.orderModel.findOne({ _id: id, storeId });
    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.status === 'Cancelled') {
      throw new ConflictException('Order is already cancelled');
    }

    const orderItems = await this.orderItemModel.find({ orderId: id });

    for (const item of orderItems) {
      await this.productModel.findByIdAndUpdate(item.productId, {
        $inc: { quantity: item.quantity },
      });
    }

    order.status = 'Cancelled';
    return order.save();
  }

  async getDashboardMetrics(storeId: string) {
    const orders = await this.orderModel.find({ storeId, status: { $ne: 'Cancelled' } });

    const totalOrders = orders.length;
    const totalRevenue = orders.reduce((sum, o) => sum + o.total, 0);
    const totalProfit = orders.reduce((sum, o) => sum + (o.profit || 0), 0);
    const pendingDeliveries = orders.filter(
      (o) => !['Delivered', 'Cancelled'].includes(o.status),
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

  async getCustomersSummary(storeId: string) {
    return this.orderModel.aggregate([
      { $match: { storeId } },
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
          _id: '$customer.phoneNumber',
          customerName: { $first: '$customer.fullName' },
          phone: { $first: '$customer.phoneNumber' },
          totalOrders: { $sum: 1 },
          totalSpent: { $sum: '$total' },
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

  async getMonthlyAnalytics(storeId: string) {
    return this.orderModel.aggregate([
      { $match: { storeId, status: { $ne: 'Cancelled' } } },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
          },
          totalRevenue: { $sum: '$total' },
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

  async getStatusBreakdown(storeId: string) {
    return this.orderModel.aggregate([
      { $match: { storeId } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalRevenue: { $sum: '$total' },
          totalProfit: { $sum: '$profit' },
        },
      },
    ]);
  }

  async getTopProducts(storeId: string, limit: number = 10) {
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
      { $match: { 'order.storeId': storeId, 'order.status': { $ne: 'Cancelled' } } },
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
          totalProfit: {
            $sum: {
              $multiply: ['$quantity', { $subtract: ['$unitPrice', '$product.costPrice'] }],
            },
          },
        },
      },
      { $sort: { totalRevenue: -1 } },
      { $limit: limit },
    ]);
  }

  async getDailySales(storeId: string, days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return this.orderModel.aggregate([
      {
        $match: {
          storeId,
          status: { $ne: 'Cancelled' },
          createdAt: { $gte: startDate },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          totalOrders: { $sum: 1 },
          totalRevenue: { $sum: '$total' },
          totalProfit: { $sum: '$profit' },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]);
  }

  async getYearlyAnalytics(storeId: string) {
    return this.orderModel.aggregate([
      { $match: { storeId, status: { $ne: 'Cancelled' } } },
      {
        $group: {
          _id: { $year: '$createdAt' },
          totalRevenue: { $sum: '$total' },
          totalProfit: { $sum: '$profit' },
          totalOrders: { $sum: 1 },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]);
  }

  async exportOrders(storeId: string): Promise<string> {
    const orders = await this.findAllByStore(storeId, {});

    if (orders.data.length === 0) {
      return '';
    }

    const fields = [
      'orderNumber',
      'customerId.fullName',
      'status',
      'subtotal',
      'total',
      'advancePaid',
      'balance',
      'profit',
      'createdAt',
    ];

    const parser = new Parser({ fields });
    return parser.parse(orders.data);
  }
}
