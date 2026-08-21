import { Test, TestingModule } from '@nestjs/testing';
import { StoresService } from './stores.service';
import { getModelToken } from '@nestjs/mongoose';

describe('StoresService', () => {
  let service: StoresService;
  let model: any;
  let userModel: any;

  const mockStoreModel: any = jest.fn();
  mockStoreModel.findOne = jest.fn();
  mockStoreModel.findOneAndUpdate = jest.fn();

  const mockUserModel: any = jest.fn();
  mockUserModel.findByIdAndUpdate = jest.fn();

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StoresService,
        {
          provide: getModelToken('Store'),
          useValue: mockStoreModel,
        },
        {
          provide: getModelToken('User'),
          useValue: mockUserModel,
        },
      ],
    }).compile();

    service = module.get<StoresService>(StoresService);
    model = module.get(getModelToken('Store'));
    userModel = module.get(getModelToken('User'));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a new store', async () => {
      const saveMock = jest.fn().mockResolvedValue({
        _id: 'store1',
        userId: 'user1',
        name: 'My Store',
        description: 'A great store',
        phone: '1234567890',
        address: '123 Main St',
      });

      mockStoreModel.mockImplementation(() => ({
        save: saveMock,
      }));

      model.findOne.mockResolvedValue(null);

      const result = await service.create(
        {
          name: 'My Store',
          description: 'A great store',
          phone: '1234567890',
          address: '123 Main St',
        },
        'user1',
      );

      expect(result._id).toBe('store1');
      expect(result.name).toBe('My Store');
      expect(userModel.findByIdAndUpdate).toHaveBeenCalledWith('user1', {
        businessName: 'My Store',
      });
    });

    it('should throw ConflictException if store already exists', async () => {
      model.findOne.mockResolvedValue({ _id: 'existing' });

      await expect(
        service.create(
          {
            name: 'My Store',
            description: 'desc',
            phone: '123',
            address: 'addr',
          },
          'user1',
        ),
      ).rejects.toThrow('You already have a store');
    });
  });

  describe('getMyStore', () => {
    it('should return the store for the given user', async () => {
      const mockStore = {
        _id: 'store1',
        userId: 'user1',
        name: 'My Store',
      };
      model.findOne.mockResolvedValue(mockStore);

      const result = await service.getMyStore('user1');
      expect(result).toEqual(mockStore);
    });

    it('should throw NotFoundException if store not found', async () => {
      model.findOne.mockResolvedValue(null);

      await expect(service.getMyStore('user1')).rejects.toThrow(
        'Store not found',
      );
    });
  });

  describe('updateStore', () => {
    it('should update and return the store', async () => {
      const mockStore = {
        _id: 'store1',
        userId: 'user1',
        name: 'Updated Store',
      };
      model.findOneAndUpdate.mockResolvedValue(mockStore);

      const result = await service.updateStore('user1', {
        name: 'Updated Store',
      });
      expect(result).toEqual(mockStore);
      expect(model.findOneAndUpdate).toHaveBeenCalledWith(
        { userId: 'user1' },
        { $set: { name: 'Updated Store' } },
        { new: true },
      );
      expect(userModel.findByIdAndUpdate).toHaveBeenCalledWith('user1', {
        businessName: 'Updated Store',
      });
    });

    it('should throw NotFoundException if store not found', async () => {
      model.findOneAndUpdate.mockResolvedValue(null);

      await expect(
        service.updateStore('user1', { name: 'Updated' }),
      ).rejects.toThrow('Store not found');
    });
  });
});
