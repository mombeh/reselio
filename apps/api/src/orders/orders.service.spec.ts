import { Test, TestingModule } from '@nestjs/testing';
import { OrdersService } from './orders.service';
import { getModelToken } from '@nestjs/mongoose';

describe('OrdersService', () => {
  let service: OrdersService;
  let model: any;

  const mockOrderModel = {
    find: jest.fn(),
    findOne: jest.fn(),
    countDocuments: jest.fn(),
    aggregate: jest.fn(),
    create: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OrdersService,
        {
          provide: getModelToken('Order'),
          useValue: mockOrderModel,
        },
      ],
    }).compile();

    service = module.get<OrdersService>(OrdersService);
    model = module.get(getModelToken('Order'));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findAllByUser', () => {
    it('should return paginated orders', async () => {
      const mockOrders = [{ customerName: 'Sarah' }];

      model.countDocuments.mockResolvedValue(1);
      model.find.mockReturnValue({
        sort: () => ({
          skip: () => ({
            limit: () => mockOrders,
          }),
        }),
      });

      const result = await service.findAllByUser('user123', {
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

      model.aggregate.mockResolvedValue(mockAnalytics);

      const result = await service.getMonthlyAnalytics('user123');

      expect(result).toEqual(mockAnalytics);
      expect(model.aggregate).toHaveBeenCalled();
    });
  });
});

import { OrdersController } from './orders.controller';
import { Order } from './schemas/order.schema';

describe('OrdersController', () => {
  let controller: OrdersController;
  let service: OrdersService;

  const mockOrdersService = {
    create: jest.fn(),
    findAllByUser: jest.fn(),
    updateStatus: jest.fn(),
    getDashboardMetrics: jest.fn(),
    getCustomersSummary: jest.fn(),
    getMonthlyAnalytics: jest.fn(),
    exportOrders: jest.fn(), // <-- add this
  };

  const userId = 'test-user-id';
  const sampleOrders: Order[] = [
    {
      _id: '1',
      userId,
      customerName: 'Alice',
      phone: '123456',
      productName: 'Red Dress',
      size: 'M',
      color: 'Red',
      costPrice: 100,
      sellingPrice: 150,
      advancePaid: 50,
      balance: 100,
      profit: 50,
      status: 'Waiting for Supplier',
      createdAt: new Date(),
      updatedAt: new Date(),
      __v: 0,
    } as any,
  ];

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [OrdersController],
      providers: [
        {
          provide: OrdersService,
          useValue: mockOrdersService,
        },
      ],
    }).compile();

    controller = module.get<OrdersController>(OrdersController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('exportOrders', () => {
    it('should return CSV string for user orders', async () => {
      mockOrdersService.exportOrders.mockResolvedValue(
        'customerName,phone,productName\nSarah,670000000,Red Dress',
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
        'customerName,phone,productName\nSarah,670000000,Red Dress',
      );
    });

    it('should handle empty order array', async () => {
      mockOrdersService.exportOrders.mockResolvedValue(''); // empty CSV

      // Mock Express response
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
});
