import { Test, TestingModule } from '@nestjs/testing';
import { ReportsService } from './reports.service';
import { getModelToken } from '@nestjs/mongoose';
import { SalesPeriod } from './dto/sales-report-query.dto';
import { RevenuePeriod } from './dto/revenue-report-query.dto';

describe('ReportsService', () => {
  let service: ReportsService;
  let orderModel: any;
  let orderItemModel: any;
  let productModel: any;
  let customerModel: any;

  const mockOrderModel = {
    find: jest.fn(),
    countDocuments: jest.fn(),
    aggregate: jest.fn(),
  };

  const mockOrderItemModel = {
    aggregate: jest.fn(),
  };

  const mockProductModel = {
    find: jest.fn(),
  };

  const mockCustomerModel = {
    countDocuments: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReportsService,
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

    service = module.get<ReportsService>(ReportsService);
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

  describe('getSalesReport', () => {
    it('should return sales summary for today by default', async () => {
      const mockOrders = [
        { _id: '1', total: 10000, profit: 3000, customerId: { fullName: 'Alice' } },
        { _id: '2', total: 15000, profit: 5000, customerId: { fullName: 'Bob' } },
      ];

      orderModel.find.mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockOrders),
      });

      const result = await service.getSalesReport('store1', {});

      expect(result.totalOrders).toBe(2);
      expect(result.totalRevenue).toBe(25000);
      expect(result.totalProfit).toBe(8000);
      expect(result.averageOrderValue).toBe(12500);
    });

    it('should return sales summary for custom date range', async () => {
      const mockOrders = [
        { _id: '1', total: 10000, profit: 3000, customerId: { fullName: 'Alice' } },
      ];

      orderModel.find.mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockOrders),
      });

      const result = await service.getSalesReport('store1', {
        period: 'custom' as SalesPeriod,
        startDate: '2026-08-01',
        endDate: '2026-08-07',
      });

      expect(result.totalOrders).toBe(1);
      expect(result.totalRevenue).toBe(10000);
      expect(result.startDate).toEqual(new Date('2026-08-01'));
      expect(result.endDate).toEqual(new Date('2026-08-07'));
    });
  });

  describe('getProductPerformance', () => {
    it('should return product performance sorted by revenue', async () => {
      const mockProducts = [
        { _id: 'prod1', name: 'Red Dress' },
        { _id: 'prod2', name: 'Blue Shirt' },
      ];

      const mockOrderItems = [
        { _id: 'item1', productId: 'prod1', quantity: 5, totalPrice: 25000 },
        { _id: 'item2', productId: 'prod2', quantity: 3, totalPrice: 15000 },
      ];

      productModel.find.mockResolvedValue(mockProducts);
      orderItemModel.aggregate.mockResolvedValue([
        { _id: 'prod1', unitsSold: 5, revenue: 25000 },
        { _id: 'prod2', unitsSold: 3, revenue: 15000 },
      ]);

      const result = await service.getProductPerformance('store1');

      expect(result).toHaveLength(2);
      expect(result[0].name).toBe('Red Dress');
      expect(result[0].unitsSold).toBe(5);
      expect(result[0].revenue).toBe(25000);
    });

    it('should return zero stats for products with no sales', async () => {
      const mockProducts = [{ _id: 'prod1', name: 'Red Dress' }];

      productModel.find.mockResolvedValue(mockProducts);
      orderItemModel.aggregate.mockResolvedValue([]);

      const result = await service.getProductPerformance('store1');

      expect(result).toHaveLength(1);
      expect(result[0].unitsSold).toBe(0);
      expect(result[0].revenue).toBe(0);
    });
  });

  describe('getCustomerReport', () => {
    it('should return customer report sorted by total spent', async () => {
      const mockResult = [
        { _id: 'cust1', customerName: 'Alice', totalOrders: 5, totalSpent: 50000 },
        { _id: 'cust2', customerName: 'Bob', totalOrders: 3, totalSpent: 30000 },
      ];

      orderModel.aggregate.mockResolvedValue(mockResult);

      const result = await service.getCustomerReport('store1');

      expect(result).toHaveLength(2);
      expect(result[0].customerName).toBe('Alice');
      expect(result[0].totalOrders).toBe(5);
      expect(result[0].totalSpent).toBe(50000);
    });
  });

  describe('getRevenueTrend', () => {
    it('should return daily revenue trend for default period', async () => {
      const mockResult = [
        { _id: '2026-08-01', revenue: 45000 },
        { _id: '2026-08-02', revenue: 62000 },
      ];

      orderModel.aggregate.mockResolvedValue(mockResult);

      const result = await service.getRevenueTrend('store1', {});

      expect(result).toHaveLength(2);
      expect(result[0].date).toBe('2026-08-01');
      expect(result[0].revenue).toBe(45000);
    });

    it('should return monthly revenue trend', async () => {
      const mockResult = [
        { _id: '2026-08', revenue: 1800000 },
      ];

      orderModel.aggregate.mockResolvedValue(mockResult);

      const result = await service.getRevenueTrend('store1', { period: 'month' as RevenuePeriod });

      expect(result).toHaveLength(1);
      expect(result[0].date).toBe('2026-08');
      expect(result[0].revenue).toBe(1800000);
    });
  });
});
