import { Test, TestingModule } from '@nestjs/testing';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';
import { SalesPeriod } from './dto/sales-report-query.dto';
import { RevenuePeriod } from './dto/revenue-report-query.dto';

describe('ReportsController', () => {
  let controller: ReportsController;

  const mockReportsService = {
    getSalesReport: jest.fn(),
    getProductPerformance: jest.fn(),
    getCustomerReport: jest.fn(),
    getRevenueTrend: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ReportsController],
      providers: [{ provide: ReportsService, useValue: mockReportsService }],
    }).compile();

    controller = module.get<ReportsController>(ReportsController);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should call service.getSalesReport with userId and query', async () => {
    const mockReport = {
      period: 'today',
      totalOrders: 10,
      totalRevenue: 50000,
      totalProfit: 15000,
      averageOrderValue: 5000,
    };

    mockReportsService.getSalesReport.mockResolvedValue(mockReport);

    const result = await controller.getSalesReport(
      { user: { userId: 'store1' } },
      { period: 'today' as SalesPeriod },
    );

    expect(mockReportsService.getSalesReport).toHaveBeenCalledWith('store1', { period: 'today' });
    expect(result).toEqual(mockReport);
  });

  it('should call service.getProductPerformance with userId', async () => {
    const mockProducts = [
      { productId: 'prod1', name: 'Red Dress', unitsSold: 10, revenue: 50000 },
    ];

    mockReportsService.getProductPerformance.mockResolvedValue(mockProducts);

    const result = await controller.getProductPerformance({ user: { userId: 'store1' } });

    expect(mockReportsService.getProductPerformance).toHaveBeenCalledWith('store1');
    expect(result).toEqual(mockProducts);
  });

  it('should call service.getCustomerReport with userId', async () => {
    const mockCustomers = [
      { customerId: 'cust1', customerName: 'Alice', totalOrders: 5, totalSpent: 50000 },
    ];

    mockReportsService.getCustomerReport.mockResolvedValue(mockCustomers);

    const result = await controller.getCustomerReport({ user: { userId: 'store1' } });

    expect(mockReportsService.getCustomerReport).toHaveBeenCalledWith('store1');
    expect(result).toEqual(mockCustomers);
  });

  it('should call service.getRevenueTrend with userId and query', async () => {
    const mockTrend = [
      { date: '2026-08-01', revenue: 45000 },
      { date: '2026-08-02', revenue: 62000 },
    ];

    mockReportsService.getRevenueTrend.mockResolvedValue(mockTrend);

    const result = await controller.getRevenueTrend(
      { user: { userId: 'store1' } },
      { period: 'week' as RevenuePeriod },
    );

    expect(mockReportsService.getRevenueTrend).toHaveBeenCalledWith('store1', { period: 'week' });
    expect(result).toEqual(mockTrend);
  });
});
