import { Test, TestingModule } from '@nestjs/testing';
import { OrdersController } from './orders.controller';
import { OrdersService } from './orders.service';
import { CustomersService } from '../customers/customers.service';

describe('OrdersController', () => {
  let controller: OrdersController;

  const mockOrdersService = {
    create: jest.fn(),
    findAllByStore: jest.fn(),
    findOne: jest.fn(),
    updateStatus: jest.fn(),
    cancelOrder: jest.fn(),
    getDashboardMetrics: jest.fn(),
    getCustomersSummary: jest.fn(),
    getMonthlyAnalytics: jest.fn(),
    getStatusBreakdown: jest.fn(),
    getTopProducts: jest.fn(),
    getDailySales: jest.fn(),
    getYearlyAnalytics: jest.fn(),
    exportOrders: jest.fn(),
    createCustomer: jest.fn(),
    findAllCustomers: jest.fn(),
    findCustomerById: jest.fn(),
    updateCustomer: jest.fn(),
    deleteCustomer: jest.fn(),
    findMyOrders: jest.fn(),
  };

  const mockCustomersService = {
    create: jest.fn(),
    findAllByStore: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [OrdersController],
      providers: [
        {
          provide: OrdersService,
          useValue: mockOrdersService,
        },
        {
          provide: CustomersService,
          useValue: mockCustomersService,
        },
      ],
    }).compile();

    controller = module.get<OrdersController>(OrdersController);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('should call service.create with userId from request', async () => {
      const dto = {
        customerId: 'cust1',
        items: [{ productId: 'prod1', quantity: 2 }],
      };
      mockOrdersService.create.mockResolvedValue({ ...dto, storeId: 'store1' });

      const result = await controller.create(dto, {
        user: { userId: 'store1' },
      });

      expect(mockOrdersService.create).toHaveBeenCalledWith('store1', dto);
      expect(result.storeId).toBe('store1');
    });
  });

  describe('getMyOrders', () => {
    it('should call service.findMyOrders with userId from request', async () => {
      mockOrdersService.findMyOrders.mockResolvedValue({
        data: [{ _id: 'ord1' }],
        total: 1,
        page: 1,
        limit: 10,
        totalPages: 1,
      });

      const result = await controller.getMyOrders(
        { user: { userId: 'user1' } },
        { status: 'Delivered' },
      );

      expect(mockOrdersService.findMyOrders).toHaveBeenCalledWith('user1', {
        status: 'Delivered',
      });
      expect(result.data[0]._id).toBe('ord1');
    });
  });

  describe('findOne', () => {
    it('should call service.findOne with id and userId from request', async () => {
      mockOrdersService.findOne.mockResolvedValue({ _id: 'ord1' });

      const result = await controller.findOne('ord1', {
        user: { userId: 'store1' },
      });

      expect(mockOrdersService.findOne).toHaveBeenCalledWith('ord1', 'store1');
      expect(result._id).toBe('ord1');
    });
  });

  describe('updateStatus', () => {
    it('should call service.updateStatus with id, userId from request, and status', async () => {
      mockOrdersService.updateStatus.mockResolvedValue({
        _id: 'ord1',
        status: 'Delivered',
      });

      const result = await controller.updateStatus(
        'ord1',
        { status: 'Delivered' },
        { user: { userId: 'store1' } },
      );

      expect(mockOrdersService.updateStatus).toHaveBeenCalledWith(
        'ord1',
        'store1',
        'Delivered',
      );
      expect(result.status).toBe('Delivered');
    });
  });

  describe('cancelOrder', () => {
    it('should call service.cancelOrder with id and userId from request', async () => {
      mockOrdersService.cancelOrder.mockResolvedValue({
        _id: 'ord1',
        status: 'Cancelled',
      });

      const result = await controller.cancelOrder('ord1', {
        user: { userId: 'store1' },
      });

      expect(mockOrdersService.cancelOrder).toHaveBeenCalledWith(
        'ord1',
        'store1',
      );
      expect(result.status).toBe('Cancelled');
    });
  });

  describe('exportOrders', () => {
    it('should return CSV string for user orders', async () => {
      mockOrdersService.exportOrders.mockResolvedValue(
        'orderNumber,customerName,status\nORD-1,Alice,Pending',
      );

      const res: any = {
        header: jest.fn().mockReturnThis(),
        attachment: jest.fn().mockReturnThis(),
        send: jest.fn(),
      };

      await controller.exportOrders({ user: { userId: 'user123' } }, res);

      expect(mockOrdersService.exportOrders).toHaveBeenCalledWith('user123');
      expect(res.header).toHaveBeenCalledWith('Content-Type', 'text/csv');
      expect(res.attachment).toHaveBeenCalledWith('orders.csv');
      expect(res.send).toHaveBeenCalledWith(
        'orderNumber,customerName,status\nORD-1,Alice,Pending',
      );
    });

    it('should handle empty order array', async () => {
      mockOrdersService.exportOrders.mockResolvedValue('');

      const res: any = {
        header: jest.fn().mockReturnThis(),
        attachment: jest.fn().mockReturnThis(),
        send: jest.fn().mockReturnThis(),
      };

      const req: any = { user: { userId: 'user123' } };

      await controller.exportOrders(req, res);

      expect(mockOrdersService.exportOrders).toHaveBeenCalledWith('user123');
      expect(res.header).toHaveBeenCalledWith('Content-Type', 'text/csv');
      expect(res.attachment).toHaveBeenCalledWith('orders.csv');
      expect(res.send).toHaveBeenCalledWith('');
    });
  });

  describe('customer endpoints', () => {
    it('should delegate createCustomer to customersService', async () => {
      const dto = { fullName: 'John Doe', phoneNumber: '1234567890' };
      mockCustomersService.create.mockResolvedValue({
        ...dto,
        storeId: 'store1',
      });

      const result = await controller.createCustomer(dto, {
        user: { userId: 'store1' },
      });

      expect(mockCustomersService.create).toHaveBeenCalledWith('store1', dto);
      expect(result.storeId).toBe('store1');
    });

    it('should delegate getAllCustomers to customersService', async () => {
      mockCustomersService.findAllByStore.mockResolvedValue([{ _id: 'cust1' }]);

      const result = await controller.getAllCustomers({
        user: { userId: 'store1' },
      });

      expect(mockCustomersService.findAllByStore).toHaveBeenCalledWith(
        'store1',
      );
      expect(result[0]._id).toBe('cust1');
    });
  });
});
