import { Test, TestingModule } from '@nestjs/testing';
import { CustomersService } from './customers.service';
import { getModelToken } from '@nestjs/mongoose';

describe('CustomersService', () => {
  let service: CustomersService;
  let model: any;

  const mockCustomerModel: any = jest.fn();
  mockCustomerModel.find = jest.fn();
  mockCustomerModel.findOne = jest.fn();
  mockCustomerModel.findOneAndUpdate = jest.fn();
  mockCustomerModel.findOneAndDelete = jest.fn();

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CustomersService,
        {
          provide: getModelToken('Customer'),
          useValue: mockCustomerModel,
        },
      ],
    }).compile();

    service = module.get<CustomersService>(CustomersService);
    model = module.get(getModelToken('Customer'));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a new customer', async () => {
      const saveMock = jest.fn().mockResolvedValue({
        _id: 'cust1',
        storeId: 'store1',
        fullName: 'John Doe',
        phoneNumber: '1234567890',
        email: 'john@example.com',
      });

      mockCustomerModel.mockImplementation(() => ({
        save: saveMock,
      }));

      const result = await service.create('store1', {
        fullName: 'John Doe',
        phoneNumber: '1234567890',
        email: 'john@example.com',
      });

      expect(result._id).toBe('cust1');
      expect(result.fullName).toBe('John Doe');
    });
  });

  describe('findAllByStore', () => {
    it('should return all customers for a store', async () => {
      const mockCustomers = [
        { _id: 'cust1', fullName: 'John Doe', storeId: 'store1' },
      ];
      model.find.mockReturnValue({
        sort: () => mockCustomers,
      });

      const result = await service.findAllByStore('store1');
      expect(result).toEqual(mockCustomers);
    });
  });

  describe('findOne', () => {
    it('should return a customer by id and storeId', async () => {
      const mockCustomer = {
        _id: 'cust1',
        fullName: 'John Doe',
        storeId: 'store1',
      };
      model.findOne.mockResolvedValue(mockCustomer);

      const result = await service.findOne('cust1', 'store1');
      expect(result).toEqual(mockCustomer);
    });

    it('should throw NotFoundException if customer not found', async () => {
      model.findOne.mockResolvedValue(null);

      await expect(service.findOne('cust1', 'store1')).rejects.toThrow(
        'Customer not found',
      );
    });
  });

  describe('update', () => {
    it('should update and return the customer', async () => {
      const mockCustomer = {
        _id: 'cust1',
        fullName: 'Jane Doe',
        storeId: 'store1',
      };
      model.findOneAndUpdate.mockResolvedValue(mockCustomer);

      const result = await service.update('cust1', 'store1', {
        fullName: 'Jane Doe',
      });
      expect(result).toEqual(mockCustomer);
      expect(model.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: 'cust1', storeId: 'store1' },
        { $set: { fullName: 'Jane Doe' } },
        { new: true },
      );
    });

    it('should throw NotFoundException if customer not found', async () => {
      model.findOneAndUpdate.mockResolvedValue(null);

      await expect(
        service.update('cust1', 'store1', { fullName: 'Jane' }),
      ).rejects.toThrow('Customer not found');
    });
  });

  describe('remove', () => {
    it('should delete and return the customer', async () => {
      const mockCustomer = {
        _id: 'cust1',
        fullName: 'John Doe',
        storeId: 'store1',
      };
      model.findOneAndDelete.mockResolvedValue(mockCustomer);

      const result = await service.remove('cust1', 'store1');
      expect(result).toEqual(mockCustomer);
      expect(model.findOneAndDelete).toHaveBeenCalledWith({
        _id: 'cust1',
        storeId: 'store1',
      });
    });

    it('should throw NotFoundException if customer not found', async () => {
      model.findOneAndDelete.mockResolvedValue(null);

      await expect(service.remove('cust1', 'store1')).rejects.toThrow(
        'Customer not found',
      );
    });
  });
});
