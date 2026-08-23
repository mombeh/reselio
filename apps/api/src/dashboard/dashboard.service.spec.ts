import { Test, TestingModule } from '@nestjs/testing';
import { DashboardService } from './dashboard.service';
import { getModelToken } from '@nestjs/mongoose';

describe('DashboardService', () => {
  let service: DashboardService;
  let orderModel: any;
  let orderItemModel: any;
  let productModel: any;
  let customerModel: any;
  let userModel: any;

  const mockOrderModel = {
    countDocuments: jest.fn(),
    aggregate: jest.fn(),
    find: jest.fn(),
  };

  const mockOrderItemModel = {
    aggregate: jest.fn(),
  };

  const mockProductModel = {
    countDocuments: jest.fn(),
  };

  const mockCustomerModel = {
    countDocuments: jest.fn(),
  };

  const mockUserModel = {
    countDocuments: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DashboardService,
        {
          provide: getModelToken('Order'),
          useValue: mockOrderModel,
        },
        {
          provide: getModelToken('OrderItem'),
          useValue: mockOrderItemModel,
        },
        {
          provide: getModelToken('Product'),
          useValue: mockProductModel,
        },
        {
          provide: getModelToken('Customer'),
          useValue: mockCustomerModel,
        },
        {
          provide: getModelToken('User'),
          useValue: mockUserModel,
        },
      ],
    }).compile();

    service = module.get<DashboardService>(DashboardService);
    orderModel = module.get(getModelToken('Order'));
    orderItemModel = module.get(getModelToken('OrderItem'));
    productModel = module.get(getModelToken('Product'));
    customerModel = module.get(getModelToken('Customer'));
    userModel = module.get(getModelToken('User'));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getDashboard', () => {
    it('should return aggregated dashboard data', async () => {
      productModel.countDocuments.mockResolvedValue(45);
      customerModel.countDocuments.mockResolvedValue(120);
      orderModel.countDocuments
        .mockResolvedValueOnce(210)
        .mockResolvedValueOnce(8)
        .mockResolvedValueOnce(180);

      orderModel.aggregate
        .mockResolvedValueOnce([{ revenue: 150000 }])
        .mockResolvedValueOnce([{ revenue: 1800000 }]);

      orderModel.find.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          sort: jest.fn().mockReturnValue({
            limit: jest.fn().mockResolvedValue([{ _id: 'ord1' }]),
          }),
        }),
      });

      orderItemModel.aggregate.mockResolvedValue([
        { _id: 'prod1', totalRevenue: 50000 },
      ]);

      const result = await service.getDashboard('store1');

      expect(result.totalProducts).toBe(45);
      expect(result.totalCustomers).toBe(120);
      expect(result.totalOrders).toBe(210);
      expect(result.pendingOrders).toBe(8);
      expect(result.completedOrders).toBe(180);
      expect(result.todayRevenue).toBe(150000);
      expect(result.monthlyRevenue).toBe(1800000);
      expect(result.recentOrders).toEqual([{ _id: 'ord1' }]);
      expect(result.topProducts).toEqual([
        { _id: 'prod1', totalRevenue: 50000 },
      ]);
    });
  });

  describe('getAdminDashboard', () => {
    it('should return platform-wide admin dashboard data', async () => {
      userModel.countDocuments
        .mockResolvedValueOnce(125)
        .mockResolvedValueOnce(1240)
        .mockResolvedValueOnce(89);
      productModel.countDocuments.mockResolvedValue(850);
      orderModel.countDocuments
        .mockResolvedValueOnce(2430)
        .mockResolvedValueOnce(320);
      orderModel.aggregate.mockResolvedValue([{ revenue: 8500000 }]);

      const result = await service.getAdminDashboard();

      expect(result.totalSellers).toBe(125);
      expect(result.totalCustomers).toBe(1240);
      expect(result.totalProducts).toBe(850);
      expect(result.totalOrders).toBe(2430);
      expect(result.pendingOrders).toBe(320);
      expect(result.totalRevenue).toBe(8500000);
      expect(result.activeUsers).toBe(89);
    });
  });
});
