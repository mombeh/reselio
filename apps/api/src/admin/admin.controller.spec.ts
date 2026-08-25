import { Test, TestingModule } from '@nestjs/testing';
import { AdminController } from './admin.controller';
import { DashboardService } from '../dashboard/dashboard.service';
import { UsersService } from '../users/users.service';
import { CustomersService } from '../customers/customers.service';
import { OrdersService } from '../orders/orders.service';
import { ProductsService } from '../products/products.service';
import { ReportsService } from '../reports/reports.service';
import { SalesPeriod } from '../reports/dto/sales-report-query.dto';
import { RevenuePeriod } from '../reports/dto/revenue-report-query.dto';
import { Role } from '../auth/enums/role.enum';

describe('AdminController', () => {
  let controller: AdminController;
  let dashboardService: jest.Mocked<DashboardService>;
  let usersService: jest.Mocked<UsersService>;
  let customersService: jest.Mocked<CustomersService>;
  let ordersService: jest.Mocked<OrdersService>;
  let productsService: jest.Mocked<ProductsService>;
  let reportsService: jest.Mocked<ReportsService>;

  const mockDashboardService = {
    getAdminDashboard: jest.fn(),
  };

  const mockUsersService = {
    findSellers: jest.fn(),
    findSellerById: jest.fn(),
    toggleSellerStatus: jest.fn(),
  };

  const mockCustomersService = {
    findAllByStore: jest.fn(),
    findOne: jest.fn(),
  };

  const mockOrdersService = {
    findAll: jest.fn(),
    getPlatformStatusBreakdown: jest.fn(),
    getPlatformDailySales: jest.fn(),
    getPlatformTopProducts: jest.fn(),
  };

  const mockProductsService = {
    findAll: jest.fn(),
  };

  const mockReportsService = {
    getPlatformSalesReport: jest.fn(),
    getPlatformRevenueTrend: jest.fn(),
    getPlatformProductPerformance: jest.fn(),
    getPlatformCustomerReport: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdminController],
      providers: [
        { provide: DashboardService, useValue: mockDashboardService },
        { provide: UsersService, useValue: mockUsersService },
        { provide: CustomersService, useValue: mockCustomersService },
        { provide: OrdersService, useValue: mockOrdersService },
        { provide: ProductsService, useValue: mockProductsService },
        { provide: ReportsService, useValue: mockReportsService },
      ],
    }).compile();

    controller = module.get<AdminController>(AdminController);
    dashboardService = module.get(DashboardService);
    usersService = module.get(UsersService);
    customersService = module.get(CustomersService);
    ordersService = module.get(OrdersService);
    productsService = module.get(ProductsService);
    reportsService = module.get(ReportsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getAdminDashboard', () => {
    it('should return admin dashboard metrics', async () => {
      mockDashboardService.getAdminDashboard.mockResolvedValue({
        totalSellers: 10,
        totalCustomers: 100,
        totalProducts: 50,
        totalOrders: 200,
        pendingOrders: 20,
        totalRevenue: 5000000,
        activeUsers: 80,
      });

      const result = await controller.getAdminDashboard();

      expect(result.totalSellers).toBe(10);
      expect(result.totalCustomers).toBe(100);
      expect(dashboardService.getAdminDashboard).toHaveBeenCalled();
    });
  });

  describe('getSellers', () => {
    it('should return paginated sellers', async () => {
      mockUsersService.findSellers.mockResolvedValue({
        data: [{ _id: 'seller1', name: 'Jane', role: Role.Client }],
        total: 1,
        page: 1,
        limit: 10,
        totalPages: 1,
      });

      const result = await controller.getSellers('Jane', undefined, '1', '10');

      expect(result.data).toHaveLength(1);
      expect(usersService.findSellers).toHaveBeenCalledWith({
        search: 'Jane',
        isActive: undefined,
        page: 1,
        limit: 10,
      });
    });
  });

  describe('getSellerById', () => {
    it('should return seller details', async () => {
      mockUsersService.findSellerById.mockResolvedValue({
        _id: 'seller1',
        name: 'Jane',
        email: 'jane@test.com',
        role: Role.Client,
        isActive: true,
      });

      const result = await controller.getSellerById('seller1');

      expect(result.name).toBe('Jane');
      expect(usersService.findSellerById).toHaveBeenCalledWith('seller1');
    });
  });

  describe('updateSellerStatus', () => {
    it('should update seller status', async () => {
      mockUsersService.toggleSellerStatus.mockResolvedValue({
        _id: 'seller1',
        name: 'Jane',
        isActive: false,
      } as any);

      const result = await controller.updateSellerStatus('seller1', false);

      expect(result.isActive).toBe(false);
      expect(usersService.toggleSellerStatus).toHaveBeenCalledWith('seller1', false);
    });
  });

  describe('getCustomers', () => {
    it('should return all customers with user info', async () => {
      mockCustomersService.findAllByStore.mockResolvedValue([
        { _id: 'cust1', fullName: 'John', phoneNumber: '123', userId: 'user1', toObject: () => ({ _id: 'cust1', fullName: 'John', phoneNumber: '123', userId: 'user1' }) },
      ] as any);
      mockUsersService.findSellerById.mockResolvedValue({ _id: 'user1', isActive: true, email: 'john@test.com' });

      const result = await controller.getCustomers();

      expect(result).toHaveLength(1);
      expect(result[0].fullName).toBe('John');
      expect(customersService.findAllByStore).toHaveBeenCalledWith(null);
    });
  });

  describe('getCustomerById', () => {
    it('should return customer details with user info', async () => {
      mockCustomersService.findOne.mockResolvedValue({
        _id: 'cust1',
        fullName: 'John',
        phoneNumber: '123',
        userId: 'user1',
        toObject: () => ({ _id: 'cust1', fullName: 'John', phoneNumber: '123', userId: 'user1' }),
      } as any);
      mockUsersService.findSellerById.mockResolvedValue({ _id: 'user1', isActive: true, email: 'john@test.com' });

      const result = await controller.getCustomerById('cust1');

      expect(result.fullName).toBe('John');
      expect(result.isActive).toBe(true);
      expect(customersService.findOne).toHaveBeenCalledWith('cust1', null);
    });
  });

  describe('updateCustomerStatus', () => {
    it('should update customer status via linked user', async () => {
      mockCustomersService.findOne.mockResolvedValue({
        _id: 'cust1',
        fullName: 'John',
        userId: 'user1',
        toObject: () => ({ _id: 'cust1', fullName: 'John', userId: 'user1' }),
      } as any);
      mockUsersService.toggleSellerStatus.mockResolvedValue({ _id: 'user1', isActive: false } as any);

      const result = await controller.updateCustomerStatus('cust1', false);

      expect(result.isActive).toBe(false);
      expect(usersService.toggleSellerStatus).toHaveBeenCalledWith('user1', false);
    });

    it('should handle customer without linked user', async () => {
      mockCustomersService.findOne.mockResolvedValue({
        _id: 'cust1',
        fullName: 'John',
        userId: null,
        toObject: () => ({ _id: 'cust1', fullName: 'John', userId: null }),
      } as any);

      const result = await controller.updateCustomerStatus('cust1', false);

      expect(result.message).toBe('Customer has no linked user account');
    });
  });

  describe('getProducts', () => {
    it('should return all products', async () => {
      mockProductsService.findAll.mockResolvedValue([
        { _id: 'prod1', name: 'Product 1', price: 100 },
      ] as any);

      const result = await controller.getProducts();

      expect(result).toHaveLength(1);
      expect(productsService.findAll).toHaveBeenCalledWith(undefined, undefined);
    });

    it('should filter products by search and category', async () => {
      mockProductsService.findAll.mockResolvedValue([]);

      await controller.getProducts('phone', 'Electronics');

      expect(productsService.findAll).toHaveBeenCalledWith('phone', 'Electronics');
    });
  });

  describe('getOrders', () => {
    it('should return all orders', async () => {
      mockOrdersService.findAll.mockResolvedValue({
        data: [{ _id: 'ord1', orderNumber: 'ORD-001' }],
        total: 1,
        page: 1,
        limit: 10,
        totalPages: 1,
      } as any);

      const result = await controller.getOrders();

      expect(result.data).toHaveLength(1);
      expect(ordersService.findAll).toHaveBeenCalledWith({});
    });

    it('should filter orders by status and search', async () => {
      mockOrdersService.findAll.mockResolvedValue({
        data: [],
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 0,
      } as any);

      await controller.getOrders('Pending', 'ORD-001');

      expect(ordersService.findAll).toHaveBeenCalledWith({
        status: 'Pending',
        search: 'ORD-001',
        page: undefined,
        limit: undefined,
      });
    });
  });

  describe('getReportsOverview', () => {
    it('should return platform reports overview', async () => {
      mockUsersService.findSellers.mockResolvedValue({ total: 10, data: [] } as any);
      mockCustomersService.findAllByStore.mockResolvedValue([
        { _id: 'cust1' },
        { _id: 'cust2' },
      ] as any);
      mockProductsService.findAll.mockResolvedValue([
        { _id: 'prod1' },
        { _id: 'prod2' },
        { _id: 'prod3' },
      ] as any);
      mockOrdersService.getPlatformStatusBreakdown.mockResolvedValue([
        { _id: 'Pending', count: 5, totalRevenue: 1000, totalProfit: 200 },
        { _id: 'Delivered', count: 20, totalRevenue: 5000, totalProfit: 1000 },
      ] as any);

      const result = await controller.getReportsOverview();

      expect(result.totalSellers).toBe(10);
      expect(result.totalCustomers).toBe(2);
      expect(result.totalProducts).toBe(3);
      expect(result.statusBreakdown).toHaveLength(2);
      expect(ordersService.getPlatformStatusBreakdown).toHaveBeenCalled();
    });
  });

  describe('getOrderStatusBreakdown', () => {
    it('should return platform order status breakdown', async () => {
      mockOrdersService.getPlatformStatusBreakdown.mockResolvedValue([
        { _id: 'Pending', count: 5 },
      ] as any);

      const result = await controller.getOrderStatusBreakdown();

      expect(result).toHaveLength(1);
      expect(ordersService.getPlatformStatusBreakdown).toHaveBeenCalled();
    });
  });

  describe('getPlatformDailySales', () => {
    it('should return platform daily sales', async () => {
      mockOrdersService.getPlatformDailySales.mockResolvedValue([
        { _id: '2024-01-01', totalRevenue: 1000, totalProfit: 200, totalOrders: 5 },
      ] as any);

      const result = await controller.getPlatformDailySales('7');

      expect(result).toHaveLength(1);
      expect(ordersService.getPlatformDailySales).toHaveBeenCalledWith(7);
    });
  });

  describe('getPlatformTopProducts', () => {
    it('should return platform top products', async () => {
      mockOrdersService.getPlatformTopProducts.mockResolvedValue([
        { _id: 'prod1', totalOrders: 10, totalRevenue: 5000 },
      ] as any);

      const result = await controller.getPlatformTopProducts('5');

      expect(result).toHaveLength(1);
      expect(ordersService.getPlatformTopProducts).toHaveBeenCalledWith(5);
    });
  });

  describe('getPlatformSalesReport', () => {
    it('should return platform sales report', async () => {
      mockReportsService.getPlatformSalesReport.mockResolvedValue({
        period: 'today',
        totalOrders: 10,
        totalRevenue: 5000,
        totalProfit: 1000,
        averageOrderValue: 500,
      });

      const result = await controller.getPlatformSalesReport({ period: SalesPeriod.TODAY });

      expect(result.totalOrders).toBe(10);
      expect(reportsService.getPlatformSalesReport).toHaveBeenCalled();
    });
  });

  describe('getPlatformRevenueTrend', () => {
    it('should return platform revenue trend', async () => {
      mockReportsService.getPlatformRevenueTrend.mockResolvedValue([
        { date: '2024-01-01', revenue: 1000 },
      ]);

      const result = await controller.getPlatformRevenueTrend({ period: RevenuePeriod.MONTH });

      expect(result).toHaveLength(1);
      expect(reportsService.getPlatformRevenueTrend).toHaveBeenCalled();
    });
  });

  describe('getPlatformProductPerformance', () => {
    it('should return platform product performance', async () => {
      mockReportsService.getPlatformProductPerformance.mockResolvedValue([
        { productId: 'prod1', name: 'Product 1', unitsSold: 10, revenue: 5000 },
      ]);

      const result = await controller.getPlatformProductPerformance();

      expect(result).toHaveLength(1);
      expect(reportsService.getPlatformProductPerformance).toHaveBeenCalled();
    });
  });

  describe('getPlatformCustomerReport', () => {
    it('should return platform customer report', async () => {
      mockReportsService.getPlatformCustomerReport.mockResolvedValue([
        { customerId: 'cust1', customerName: 'John', totalOrders: 5, totalSpent: 1000 },
      ]);

      const result = await controller.getPlatformCustomerReport();

      expect(result).toHaveLength(1);
      expect(reportsService.getPlatformCustomerReport).toHaveBeenCalled();
    });
  });
});
