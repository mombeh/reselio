import { Test, TestingModule } from '@nestjs/testing';
import { DashboardService } from './dashboard.service';
import { getModelToken } from '@nestjs/mongoose';

describe('DashboardService', () => {
  let service: DashboardService;
  let orderModel: any;
  let orderItemModel: any;
  let productModel: any;
  let customerModel: any;

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
      ],
    }).compile();

    service = module.get<DashboardService>(DashboardService);
    orderModel = module.get(getModelToken('Order'));
    orderItemModel = module.get(getModelToken('OrderItem'));
    productModel = module.get(getModelToken('Product'));
    customerModel = module.get(getModelToken('Customer'));
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
});
