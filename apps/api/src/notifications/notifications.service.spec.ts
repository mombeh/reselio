import { Test, TestingModule } from '@nestjs/testing';
import { NotificationsService } from './notifications.service';
import { getModelToken } from '@nestjs/mongoose';
import { NotificationType } from './enums/notification-type.enum';

describe('NotificationsService', () => {
  let service: NotificationsService;
  let model: any;

  const mockNotificationModel: any = jest.fn();
  mockNotificationModel.find = jest.fn();
  mockNotificationModel.findOne = jest.fn();
  mockNotificationModel.findOneAndUpdate = jest.fn();
  mockNotificationModel.updateMany = jest.fn();

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsService,
        {
          provide: getModelToken('Notification'),
          useValue: mockNotificationModel,
        },
      ],
    }).compile();

    service = module.get<NotificationsService>(NotificationsService);
    model = module.get(getModelToken('Notification'));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a new notification', async () => {
      const saveMock = jest.fn().mockResolvedValue({
        _id: 'notif1',
        userId: 'user1',
        type: NotificationType.ORDER_CREATED,
        title: 'New Order',
        message: 'Order received',
        isRead: false,
      });

      mockNotificationModel.mockImplementation(() => ({
        save: saveMock,
      }));

      const result = await service.create('user1', {
        type: NotificationType.ORDER_CREATED,
        title: 'New Order',
        message: 'Order received',
      });

      expect(result._id).toBe('notif1');
      expect(result.type).toBe(NotificationType.ORDER_CREATED);
    });
  });

  describe('findAllByUser', () => {
    it('should return all notifications for a user', async () => {
      const mockNotifications = [
        { _id: 'notif1', title: 'New Order', userId: 'user1' },
      ];
      model.find.mockReturnValue({
        sort: () => mockNotifications,
      });

      const result = await service.findAllByUser('user1');
      expect(result).toEqual(mockNotifications);
    });
  });

  describe('findOne', () => {
    it('should return a notification by id and userId', async () => {
      const mockNotification = { _id: 'notif1', title: 'New Order', userId: 'user1' };
      model.findOne.mockResolvedValue(mockNotification);

      const result = await service.findOne('notif1', 'user1');
      expect(result).toEqual(mockNotification);
    });

    it('should throw NotFoundException if notification not found', async () => {
      model.findOne.mockResolvedValue(null);

      await expect(service.findOne('notif1', 'user1')).rejects.toThrow(
        'Notification not found',
      );
    });
  });

  describe('markAsRead', () => {
    it('should mark notification as read', async () => {
      const mockNotification = { _id: 'notif1', isRead: true };
      model.findOneAndUpdate.mockResolvedValue(mockNotification);

      const result = await service.markAsRead('notif1', 'user1');
      expect(result.isRead).toBe(true);
    });

    it('should throw NotFoundException if notification not found', async () => {
      model.findOneAndUpdate.mockResolvedValue(null);

      await expect(service.markAsRead('notif1', 'user1')).rejects.toThrow(
        'Notification not found',
      );
    });
  });

  describe('markAllAsRead', () => {
    it('should mark all notifications as read', async () => {
      model.updateMany.mockResolvedValue({ modifiedCount: 5 });

      const result = await service.markAllAsRead('user1');
      expect(result.modifiedCount).toBe(5);
    });
  });

  describe('createLowStockNotification', () => {
    it('should create low stock notification if no unread one exists', async () => {
      model.findOne.mockResolvedValue(null);

      const saveMock = jest.fn().mockResolvedValue({
        _id: 'notif1',
        type: NotificationType.LOW_STOCK,
      });
      mockNotificationModel.mockImplementation(() => ({
        save: saveMock,
      }));

      const result = await service.createLowStockNotification('user1', 'prod1', 'Red Dress', 2);

      expect(result).toBeDefined();
      expect(result!.type).toBe(NotificationType.LOW_STOCK);
    });

    it('should not create duplicate low stock notification if unread one exists', async () => {
      model.findOne.mockResolvedValue({ _id: 'existing' });

      const result = await service.createLowStockNotification('user1', 'prod1', 'Red Dress', 2);

      expect(result).toBeNull();
    });
  });
});
