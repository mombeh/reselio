import { Test, TestingModule } from '@nestjs/testing';
import { OrdersService } from './orders.service';
import { getModelToken } from '@nestjs/mongoose';
import { NotificationsService } from '../notifications/notifications.service';

describe('OrdersService', () => {
  let service: OrdersService;
  let orderModel: any;
  let orderItemModel: any;
  let customerModel: any;
  let productModel: any;

  const mockOrderModel = jest.fn();
  mockOrderModel.find = jest.fn();
  mockOrderModel.findOne = jest.fn();
  mockOrderModel.findOneAndUpdate = jest.fn();
  mockOrderModel.countDocuments = jest.fn();
  mockOrderModel.aggregate = jest.fn();
  mockOrderModel.create = jest.fn();
  mockOrderModel.findByIdAndDelete = jest.fn();

  const mockOrderItemModel = jest.fn();
  mockOrderItemModel.find = jest.fn();
  mockOrderItemModel.findOne = jest.fn();
  mockOrderItemModel.findOneAndUpdate = jest.fn();
  mockOrderItemModel.findOneAndDelete = jest.fn();
  mockOrderItemModel.create = jest.fn();
  mockOrderItemModel.deleteMany = jest.fn();

  const mockCustomerModel = {
    findOne: jest.fn(),
  };

  const mockProductModel = {
    findOne: jest.fn(),
    findByIdAndUpdate: jest.fn(),
  };

  const mockNotificationsService = {
    create: jest.fn(),
    createLowStockNotification: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OrdersService,
        {
          provide: getModelToken('Order'),
          useValue: mockOrderModel,
        },
        {
          provide: getModelToken('OrderItem'),
          useValue: mockOrderItemModel,
        },
        {
          provide: getModelToken('Customer'),
          useValue: mockCustomerModel,
        },
        {
          provide: getModelToken('Product'),
          useValue: mockProductModel,
        },
        {
          provide: NotificationsService,
          useValue: mockNotificationsService,
        },
      ],
    }).compile();

    service = module.get<OrdersService>(OrdersService);
    orderModel = module.get(getModelToken('Order'));
    orderItemModel = module.get(getModelToken('OrderItem'));
    customerModel = module.get(getModelToken('Customer'));
    productModel = module.get(getModelToken('Product'));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findAllByStore', () => {
    it('should return paginated orders', async () => {
      const mockOrders = [{ orderNumber: 'ORD-1', customerId: { fullName: 'Alice' } }];

      orderModel.countDocuments.mockResolvedValue(1);
      orderModel.find.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          sort: () => ({
            skip: () => ({
              limit: () => mockOrders,
            }),
          }),
        }),
      });

      const result = await service.findAllByStore('user123', {
        page: '1',
        limit: '10',
      });

      expect(result.total).toBe(1);
      expect(result.data).toEqual(mockOrders);
      expect(result.page).toBe(1);
    });
  });

  describe('getMonthlyAnalytics', () => {
    it('should return aggregated monthly data', async () => {
      const mockAnalytics = [
        {
          _id: { year: 2026, month: 3 },
          totalRevenue: 50000,
          totalProfit: 15000,
          totalOrders: 3,
        },
      ];

      orderModel.aggregate.mockResolvedValue(mockAnalytics);

      const result = await service.getMonthlyAnalytics('user123');

      expect(result).toEqual(mockAnalytics);
      expect(orderModel.aggregate).toHaveBeenCalled();
    });
  });

  describe('create', () => {
    it('should create an order and decrement stock', async () => {
      customerModel.findOne.mockResolvedValue({ _id: 'cust1', storeId: 'store1' });
      orderModel.findOne.mockResolvedValue(null);
      orderModel.countDocuments.mockResolvedValue(0);
      orderItemModel.find.mockReturnValue({
        populate: jest.fn().mockResolvedValue([]),
      });

      const mockSavedOrder = {
        _id: 'order1',
        storeId: 'store1',
        customerId: 'cust1',
        orderNumber: 'ORD-123',
        status: 'Pending',
        subtotal: 10000,
        total: 10000,
        advancePaid: 0,
        balance: 10000,
        profit: 2000,
        populate: jest.fn().mockResolvedValue({
          _id: 'order1',
          storeId: 'store1',
          customerId: { fullName: 'John', phoneNumber: '123', email: 'john@test.com' },
          orderNumber: 'ORD-123',
          status: 'Pending',
          subtotal: 10000,
          total: 10000,
          advancePaid: 0,
          balance: 10000,
          profit: 2000,
          toObject: jest.fn().mockReturnValue({
            _id: 'order1',
            storeId: 'store1',
            customerId: { fullName: 'John', phoneNumber: '123', email: 'john@test.com' },
            orderNumber: 'ORD-123',
            status: 'Pending',
            subtotal: 10000,
            total: 10000,
            advancePaid: 0,
            balance: 10000,
            profit: 2000,
          }),
        }),
      };

      mockOrderModel.mockImplementation(() => ({
        save: jest.fn().mockResolvedValue(mockSavedOrder),
      }));

      mockOrderItemModel.mockImplementation(() => ({
        save: jest.fn().mockResolvedValue({ _id: 'item1', orderId: 'order1' }),
        find: jest.fn().mockReturnValue({
          populate: jest.fn().mockResolvedValue([]),
        }),
      }));

      productModel.findOne.mockResolvedValue({
        _id: 'prod1',
        storeId: 'store1',
        name: 'Product 1',
        price: 5000,
        quantity: 10,
        costPrice: 3000,
      });
      productModel.findByIdAndUpdate.mockResolvedValue({
        _id: 'prod1',
        storeId: 'store1',
        name: 'Product 1',
        price: 5000,
        quantity: 8,
        costPrice: 3000,
      });

      const result = await service.create('store1', {
        customerId: 'cust1',
        items: [{ productId: 'prod1', quantity: 2 }],
      });

      expect(result.orderNumber).toBe('ORD-123');
      expect(productModel.findByIdAndUpdate).toHaveBeenCalledWith('prod1', {
        $inc: { quantity: -2 },
      }, { new: true });
    });

    it('should throw ConflictException when quantity exceeds stock', async () => {
      customerModel.findOne.mockResolvedValue({ _id: 'cust1', storeId: 'store1' });
      orderModel.findOne.mockResolvedValue(null);
      productModel.findOne.mockResolvedValue({
        _id: 'prod1',
        storeId: 'store1',
        name: 'Product 1',
        price: 5000,
        quantity: 1,
        costPrice: 3000,
      });

      await expect(
        service.create('store1', {
          customerId: 'cust1',
          items: [{ productId: 'prod1', quantity: 5 }],
        }),
      ).rejects.toThrow('Insufficient stock for Product 1. Available: 1');
    });

    it('should throw ConflictException when stock would go negative', async () => {
      customerModel.findOne.mockResolvedValue({ _id: 'cust1', storeId: 'store1' });
      orderModel.findOne.mockResolvedValue(null);
      orderModel.countDocuments.mockResolvedValue(0);
      orderItemModel.find.mockReturnValue({
        populate: jest.fn().mockResolvedValue([]),
      });

      const mockSavedOrder = {
        _id: 'order1',
        storeId: 'store1',
        customerId: 'cust1',
        orderNumber: 'ORD-123',
        status: 'Pending',
        subtotal: 5000,
        total: 5000,
        advancePaid: 0,
        balance: 5000,
        profit: 1000,
        populate: jest.fn().mockResolvedValue({
          _id: 'order1',
          storeId: 'store1',
          customerId: { fullName: 'John', phoneNumber: '123', email: 'john@test.com' },
          orderNumber: 'ORD-123',
          status: 'Pending',
          subtotal: 5000,
          total: 5000,
          advancePaid: 0,
          balance: 5000,
          profit: 1000,
          toObject: jest.fn().mockReturnValue({
            _id: 'order1',
            storeId: 'store1',
            customerId: { fullName: 'John', phoneNumber: '123', email: 'john@test.com' },
            orderNumber: 'ORD-123',
            status: 'Pending',
            subtotal: 5000,
            total: 5000,
            advancePaid: 0,
            balance: 5000,
            profit: 1000,
          }),
        }),
      };

      mockOrderModel.mockImplementation(() => ({
        save: jest.fn().mockResolvedValue(mockSavedOrder),
      }));

      mockOrderItemModel.mockImplementation(() => ({
        save: jest.fn().mockResolvedValue({ _id: 'item1', orderId: 'order1' }),
        find: jest.fn().mockReturnValue({
          populate: jest.fn().mockResolvedValue([]),
        }),
      }));

      productModel.findOne.mockResolvedValue({
        _id: 'prod1',
        storeId: 'store1',
        name: 'Product 1',
        price: 5000,
        quantity: 10,
        costPrice: 3000,
      });
      productModel.findByIdAndUpdate.mockResolvedValue({
        _id: 'prod1',
        storeId: 'store1',
        name: 'Product 1',
        price: 5000,
        quantity: -1,
        costPrice: 3000,
      });

      await expect(
        service.create('store1', {
          customerId: 'cust1',
          items: [{ productId: 'prod1', quantity: 6 }],
        }),
      ).rejects.toThrow('Insufficient stock for product prod1. Stock cannot be negative.');
    });

    it('should throw ConflictException for empty items', async () => {
      customerModel.findOne.mockResolvedValue({ _id: 'cust1', storeId: 'store1' });

      await expect(
        service.create('store1', {
          customerId: 'cust1',
          items: [],
        }),
      ).rejects.toThrow('Order must contain at least one item');
    });

    it('should throw NotFoundException for missing customer', async () => {
      customerModel.findOne.mockResolvedValue(null);

      await expect(
        service.create('store1', {
          customerId: 'cust1',
          items: [{ productId: 'prod1', quantity: 1 }],
        }),
      ).rejects.toThrow('Customer not found in your store');
    });
  });

  describe('updateStatus', () => {
    it('should throw ConflictException when updating delivered order', async () => {
      orderModel.findOne.mockResolvedValue({
        _id: 'order1',
        storeId: 'store1',
        status: 'Delivered',
      });

      await expect(
        service.updateStatus('order1', 'store1', 'Cancelled'),
      ).rejects.toThrow('Cannot update status of an order that is already delivered');
    });

    it('should throw ConflictException when updating cancelled order', async () => {
      orderModel.findOne.mockResolvedValue({
        _id: 'order1',
        storeId: 'store1',
        status: 'Cancelled',
      });

      await expect(
        service.updateStatus('order1', 'store1', 'Pending'),
      ).rejects.toThrow('Cannot update status of an order that is already cancelled');
    });

    it('should throw ConflictException for invalid status transition', async () => {
      orderModel.findOne.mockResolvedValue({
        _id: 'order1',
        storeId: 'store1',
        status: 'Pending',
      });

      await expect(
        service.updateStatus('order1', 'store1', 'Delivered'),
      ).rejects.toThrow('Invalid status transition from Pending to Delivered');
    });
  });

  describe('cancelOrder', () => {
    it('should cancel order and restore stock', async () => {
      orderModel.findOne.mockResolvedValue({
        _id: 'order1',
        storeId: 'store1',
        status: 'Pending',
        orderNumber: 'ORD-123',
        save: jest.fn().mockResolvedValue({
          _id: 'order1',
          storeId: 'store1',
          status: 'Cancelled',
          orderNumber: 'ORD-123',
        }),
      });
      orderItemModel.find.mockResolvedValue([
        { productId: 'prod1', quantity: 2 },
      ]);

      const result = await service.cancelOrder('order1', 'store1');
      expect(result.status).toBe('Cancelled');
      expect(productModel.findByIdAndUpdate).toHaveBeenCalledWith('prod1', {
        $inc: { quantity: 2 },
      });
    });

    it('should throw ConflictException when cancelling already cancelled order', async () => {
      orderModel.findOne.mockResolvedValue({
        _id: 'order1',
        storeId: 'store1',
        status: 'Cancelled',
      });

      await expect(service.cancelOrder('order1', 'store1')).rejects.toThrow(
        'Order is already cancelled',
      );
    });

    it('should throw ConflictException when cancelling delivered order', async () => {
      orderModel.findOne.mockResolvedValue({
        _id: 'order1',
        storeId: 'store1',
        status: 'Delivered',
      });

      await expect(service.cancelOrder('order1', 'store1')).rejects.toThrow(
        'Delivered orders cannot be cancelled',
      );
    });
  });
});
