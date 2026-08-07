import { Test, TestingModule } from '@nestjs/testing';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';

describe('DashboardController', () => {
  let controller: DashboardController;

  const mockDashboardService = {
    getDashboard: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [DashboardController],
      providers: [
        { provide: DashboardService, useValue: mockDashboardService },
      ],
    }).compile();

    controller = module.get<DashboardController>(DashboardController);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should call service.getDashboard with userId from request', async () => {
    const mockDashboard = {
      totalProducts: 45,
      totalCustomers: 120,
      totalOrders: 210,
      pendingOrders: 8,
      completedOrders: 180,
      todayRevenue: 150000,
      monthlyRevenue: 1800000,
      recentOrders: [],
      topProducts: [],
    };

    mockDashboardService.getDashboard.mockResolvedValue(mockDashboard);

    const result = await controller.getDashboard({
      user: { userId: 'store1' },
    });

    expect(mockDashboardService.getDashboard).toHaveBeenCalledWith('store1');
    expect(result).toEqual(mockDashboard);
  });
});
