import { Test, TestingModule } from '@nestjs/testing';
import { OrdersService } from './orders.service';
import { getModelToken } from '@nestjs/mongoose';

describe('OrdersService', () => {
  let service: OrdersService;
  let orderModel: any;
  let orderItemModel: any;
  let customerModel: any;
  let productModel: any;

  const mockOrderModel = {
    find: jest.fn(),
    findOne: jest.fn(),
    findOneAndUpdate: jest.fn(),
    countDocuments: jest.fn(),
    aggregate: jest.fn(),
    create: jest.fn(),
  };

  const mockOrderItemModel = {
    find: jest.fn(),
    findOne: jest.fn(),
    findOneAndUpdate: jest.fn(),
    findOneAndDelete: jest.fn(),
    create: jest.fn(),
  };

  const mockCustomerModel = {
    findOne: jest.fn(),
  };

  const mockProductModel = {
    findOne: jest.fn(),
    findByIdAndUpdate: jest.fn(),
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
});
