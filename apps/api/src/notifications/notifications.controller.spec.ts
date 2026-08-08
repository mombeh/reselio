import { Test, TestingModule } from '@nestjs/testing';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';

describe('NotificationsController', () => {
  let controller: NotificationsController;

  const mockNotificationsService = {
    findAllByUser: jest.fn(),
    findOne: jest.fn(),
    markAsRead: jest.fn(),
    markAllAsRead: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [NotificationsController],
      providers: [{ provide: NotificationsService, useValue: mockNotificationsService }],
    }).compile();

    controller = module.get<NotificationsController>(NotificationsController);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should call service.findAllByUser with userId from request', async () => {
    mockNotificationsService.findAllByUser.mockResolvedValue([{ _id: 'notif1' }]);

    const result = await controller.findAll({ user: { userId: 'user1' } });

    expect(mockNotificationsService.findAllByUser).toHaveBeenCalledWith('user1');
    expect(result[0]._id).toBe('notif1');
  });

  it('should call service.markAsRead with id and userId from request', async () => {
    mockNotificationsService.markAsRead.mockResolvedValue({ _id: 'notif1', isRead: true });

    const result = await controller.markAsRead('notif1', { user: { userId: 'user1' } });

    expect(mockNotificationsService.markAsRead).toHaveBeenCalledWith('notif1', 'user1');
    expect(result.isRead).toBe(true);
  });

  it('should call service.markAllAsRead with userId from request', async () => {
    mockNotificationsService.markAllAsRead.mockResolvedValue({ modifiedCount: 5 });

    const result = await controller.markAllAsRead({ user: { userId: 'user1' } });

    expect(mockNotificationsService.markAllAsRead).toHaveBeenCalledWith('user1');
    expect(result.modifiedCount).toBe(5);
  });
});
