import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { getModelToken } from '@nestjs/mongoose';
import { Role } from '../auth/enums/role.enum';

describe('UsersService', () => {
  let service: UsersService;
  let userModel: any;

  const createQueryChain = (result: any) => {
    const chain: any = {
      select: jest.fn(function() { return chain; }),
      sort: jest.fn(function() { return chain; }),
      skip: jest.fn(function() { return chain; }),
      limit: jest.fn(function() { return chain; }),
      exec: jest.fn().mockResolvedValue(result),
      then: jest.fn(function(resolve: any) { return resolve(result); }),
    };
    return chain;
  };

  const mockUserModel = {
    find: jest.fn(),
    findOne: jest.fn(),
    findById: jest.fn((id: string) => createQueryChain(null)),
    countDocuments: jest.fn(),
    create: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getModelToken('User'),
          useValue: mockUserModel,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    userModel = module.get(getModelToken('User'));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findSellers', () => {
    it('should return paginated sellers', async () => {
      const mockSellers = [
        { _id: '1', name: 'Jane', email: 'jane@test.com', role: Role.Client },
      ];
      userModel.countDocuments.mockResolvedValue(1);
      userModel.find.mockReturnValue(createQueryChain(mockSellers));

      const result = await service.findSellers({ page: 1, limit: 10 });

      expect(result.data).toEqual(mockSellers);
      expect(result.total).toBe(1);
      expect(result.page).toBe(1);
      expect(result.limit).toBe(10);
      expect(userModel.find).toHaveBeenCalledWith({ role: Role.Client });
    });

    it('should filter by isActive', async () => {
      userModel.countDocuments.mockResolvedValue(1);
      userModel.find.mockReturnValue(createQueryChain([]));

      await service.findSellers({ isActive: true });

      expect(userModel.find).toHaveBeenCalledWith({ role: Role.Client, isActive: true });
    });
  });

  describe('findSellerById', () => {
    it('should return seller by id', async () => {
      const mockSeller = { _id: '1', name: 'Jane', role: Role.Client };
      mockUserModel.findById.mockReturnValue(createQueryChain(mockSeller));

      const result = await service.findSellerById('1');

      expect(result).toEqual(mockSeller);
      expect(userModel.findById).toHaveBeenCalledWith('1');
    });

    it('should throw error if seller not found', async () => {
      mockUserModel.findById.mockReturnValue(createQueryChain(null));

      await expect(service.findSellerById('1')).rejects.toThrow('Seller not found');
    });
  });

  describe('toggleSellerStatus', () => {
    it('should toggle seller active status', async () => {
      const mockSeller = {
        _id: '1',
        name: 'Jane',
        role: Role.Client,
        isActive: true,
        save: jest.fn().mockResolvedValue({ _id: '1', isActive: false }),
      };
      mockUserModel.findById.mockReturnValue(createQueryChain(mockSeller));

      const result = await service.toggleSellerStatus('1', false);

      expect(result.isActive).toBe(false);
      expect(mockSeller.save).toHaveBeenCalled();
    });

    it('should throw error if user is not a seller', async () => {
      const mockUser = {
        _id: '1',
        name: 'John',
        role: Role.Customer,
      };
      mockUserModel.findById.mockReturnValue(createQueryChain(mockUser));

      await expect(service.toggleSellerStatus('1', true)).rejects.toThrow('User is not a seller');
    });

    it('should throw error if seller not found', async () => {
      mockUserModel.findById.mockReturnValue(createQueryChain(null));

      await expect(service.toggleSellerStatus('1', true)).rejects.toThrow('Seller not found');
    });
  });
});
