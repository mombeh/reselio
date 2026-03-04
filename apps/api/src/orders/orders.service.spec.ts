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