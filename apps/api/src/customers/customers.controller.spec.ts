import { Test, TestingModule } from '@nestjs/testing';
import { CustomersController } from './customers.controller';
import { CustomersService } from './customers.service';

describe('CustomersController', () => {
  let controller: CustomersController;

  const mockCustomersService = {
    create: jest.fn(),
    findAllByStore: jest.fn(),
    findOne: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CustomersController],
      providers: [
        { provide: CustomersService, useValue: mockCustomersService },
      ],
    }).compile();

    controller = module.get<CustomersController>(CustomersController);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should call service.create with userId from request', async () => {
    const dto = {
      fullName: 'John Doe',
      phoneNumber: '1234567890',
      email: 'john@example.com',
    };
    mockCustomersService.create.mockResolvedValue({
      ...dto,
      storeId: 'store1',
    });

    const result = await controller.create(dto, { user: { userId: 'store1' } });

    expect(mockCustomersService.create).toHaveBeenCalledWith('store1', dto);
    expect(result.storeId).toBe('store1');
  });

  it('should call service.findAllByStore with userId from request', async () => {
    mockCustomersService.findAllByStore.mockResolvedValue([{ _id: 'cust1' }]);

    const result = await controller.findAll({ user: { userId: 'store1' } });

    expect(mockCustomersService.findAllByStore).toHaveBeenCalledWith('store1');
    expect(result[0]._id).toBe('cust1');
  });

  it('should call service.findOne with id and userId from request', async () => {
    mockCustomersService.findOne.mockResolvedValue({ _id: 'cust1' });

    const result = await controller.findOne('cust1', {
      user: { userId: 'store1' },
    });

    expect(mockCustomersService.findOne).toHaveBeenCalledWith(
      'cust1',
      'store1',
    );
    expect(result._id).toBe('cust1');
  });

  it('should call service.update with id and userId from request', async () => {
    const dto = { fullName: 'Jane Doe' };
    mockCustomersService.update.mockResolvedValue({ ...dto, _id: 'cust1' });

    const result = await controller.update('cust1', dto, {
      user: { userId: 'store1' },
    });

    expect(mockCustomersService.update).toHaveBeenCalledWith(
      'cust1',
      'store1',
      dto,
    );
    expect(result.fullName).toBe('Jane Doe');
  });

  it('should call service.remove with id and userId from request', async () => {
    mockCustomersService.remove.mockResolvedValue({ _id: 'cust1' });

    const result = await controller.remove('cust1', {
      user: { userId: 'store1' },
    });

    expect(mockCustomersService.remove).toHaveBeenCalledWith('cust1', 'store1');
    expect(result._id).toBe('cust1');
  });
});
