import { Test, TestingModule } from '@nestjs/testing';
import { ProductsController } from './products.controller';
import { ProductsService } from './products.service';

describe('ProductsController', () => {
  let controller: ProductsController;

  const mockProductsService = {
    create: jest.fn(),
    findAllByStore: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProductsController],
      providers: [{ provide: ProductsService, useValue: mockProductsService }],
    }).compile();

    controller = module.get<ProductsController>(ProductsController);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should call service.create with userId from request', async () => {
    const dto = {
      name: 'Red Dress',
      description: 'A beautiful red dress',
      price: 5000,
      quantity: 10,
      category: 'Dresses',
    };
    mockProductsService.create.mockResolvedValue({ ...dto, storeId: 'store1' });

    const result = await controller.create(dto, { user: { userId: 'store1' } });

    expect(mockProductsService.create).toHaveBeenCalledWith('store1', dto);
    expect(result.storeId).toBe('store1');
  });

  it('should call service.findAllByStore with userId from request', async () => {
    mockProductsService.findAllByStore.mockResolvedValue([{ _id: 'prod1' }]);

    const result = await controller.findAll({ user: { userId: 'store1' } });

    expect(mockProductsService.findAllByStore).toHaveBeenCalledWith('store1');
    expect(result[0]._id).toBe('prod1');
  });

  it('should call service.findOne with id and userId from request', async () => {
    mockProductsService.findOne.mockResolvedValue({ _id: 'prod1' });

    const result = await controller.findOne('prod1', {
      user: { userId: 'store1' },
    });

    expect(mockProductsService.findOne).toHaveBeenCalledWith('prod1', 'store1');
    expect(result._id).toBe('prod1');
  });

  it('should call service.update with id and userId from request', async () => {
    const dto = { name: 'Updated Dress' };
    mockProductsService.update.mockResolvedValue({ ...dto, _id: 'prod1' });

    const result = await controller.update('prod1', dto, {
      user: { userId: 'store1' },
    });

    expect(mockProductsService.update).toHaveBeenCalledWith(
      'prod1',
      'store1',
      dto,
    );
    expect(result.name).toBe('Updated Dress');
  });

  it('should call service.remove with id and userId from request', async () => {
    mockProductsService.remove.mockResolvedValue({ _id: 'prod1' });

    const result = await controller.remove('prod1', {
      user: { userId: 'store1' },
    });

    expect(mockProductsService.remove).toHaveBeenCalledWith('prod1', 'store1');
    expect(result._id).toBe('prod1');
  });
});
