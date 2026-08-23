import { Test, TestingModule } from '@nestjs/testing';
import { AdminController } from './admin.controller';
import { DashboardService } from '../dashboard/dashboard.service';
import { UsersService } from '../users/users.service';
import { CustomersService } from '../customers/customers.service';
import { Role } from '../auth/enums/role.enum';

describe('AdminController', () => {
  let controller: AdminController;
  let dashboardService: jest.Mocked<DashboardService>;
  let usersService: jest.Mocked<UsersService>;
  let customersService: jest.Mocked<CustomersService>;

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

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdminController],
      providers: [
        { provide: DashboardService, useValue: mockDashboardService },
        { provide: UsersService, useValue: mockUsersService },
        { provide: CustomersService, useValue: mockCustomersService },
      ],
    }).compile();

    controller = module.get<AdminController>(AdminController);
    dashboardService = module.get(DashboardService);
    usersService = module.get(UsersService);
    customersService = module.get(CustomersService);
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
});
