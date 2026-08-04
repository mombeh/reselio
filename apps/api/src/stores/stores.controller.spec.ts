import { Test, TestingModule } from '@nestjs/testing';
import { StoresController } from './stores.controller';
import { StoresService } from './stores.service';

describe('StoresController', () => {
  let controller: StoresController;
  let service: StoresService;

  const mockStoresService = {
    create: jest.fn(),
    getMyStore: jest.fn(),
    updateStore: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [StoresController],
      providers: [{ provide: StoresService, useValue: mockStoresService }],
    }).compile();

    controller = module.get<StoresController>(StoresController);
    service = module.get<StoresService>(StoresService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should call service.create with userId from request', async () => {
    const dto = {
      name: 'My Store',
      description: 'desc',
      phone: '123',
      address: 'addr',
    };
    mockStoresService.create.mockResolvedValue({ ...dto, userId: 'user1' });

    const result = await controller.create(dto, { user: { userId: 'user1' } });

    expect(mockStoresService.create).toHaveBeenCalledWith(dto, 'user1');
    expect(result.userId).toBe('user1');
  });

  it('should call service.getMyStore with userId from request', async () => {
    mockStoresService.getMyStore.mockResolvedValue({ _id: 'store1' });

    const result = await controller.getMyStore({ user: { userId: 'user1' } });

    expect(mockStoresService.getMyStore).toHaveBeenCalledWith('user1');
    expect(result._id).toBe('store1');
  });

  it('should call service.updateStore with userId from request', async () => {
    const dto = { name: 'Updated Store' };
    mockStoresService.updateStore.mockResolvedValue({
      ...dto,
      userId: 'user1',
    });

    const result = await controller.updateStore(dto, {
      user: { userId: 'user1' },
    });

    expect(mockStoresService.updateStore).toHaveBeenCalledWith('user1', dto);
    expect(result.name).toBe('Updated Store');
  });
});
