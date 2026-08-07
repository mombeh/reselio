import { Test, TestingModule } from '@nestjs/testing';
import { ProductsService } from './products.service';
import { getModelToken } from '@nestjs/mongoose';

describe('ProductsService', () => {
  let service: ProductsService;
  let model: any;

  const mockProductModel: any = jest.fn();
  mockProductModel.find = jest.fn();
  mockProductModel.findOne = jest.fn();
  mockProductModel.findOneAndUpdate = jest.fn();
  mockProductModel.findOneAndDelete = jest.fn();

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductsService,
        {
          provide: getModelToken('Product'),
          useValue: mockProductModel,
        },
      ],
    }).compile();

    service = module.get<ProductsService>(ProductsService);
    model = module.get(getModelToken('Product'));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a new product with a publicId', async () => {
      const saveMock = jest.fn().mockResolvedValue({
        _id: 'prod1',
        storeId: 'store1',
        name: 'Red Dress',
        description: 'A beautiful red dress',
        price: 5000,
        quantity: 10,
        category: 'Dresses',
        publicId: 'abc123',
      });

      mockProductModel.mockImplementation(() => ({
        save: saveMock,
      }));

      const result = await service.create('store1', {
        name: 'Red Dress',
        description: 'A beautiful red dress',
        price: 5000,
        quantity: 10,
        category: 'Dresses',
      });

      expect(result._id).toBe('prod1');
      expect(result.name).toBe('Red Dress');
      expect(result.publicId).toBeDefined();
    });
  });

  describe('findAllByStore', () => {
    it('should return all products for a store', async () => {
      const mockProducts = [
        { _id: 'prod1', name: 'Red Dress', storeId: 'store1' },
      ];
      model.find.mockReturnValue({
        sort: () => mockProducts,
      });

      const result = await service.findAllByStore('store1');
      expect(result).toEqual(mockProducts);
    });
  });

  describe('findOne', () => {
    it('should return a product by id and storeId', async () => {
      const mockProduct = {
        _id: 'prod1',
        name: 'Red Dress',
        storeId: 'store1',
      };
      model.findOne.mockResolvedValue(mockProduct);

      const result = await service.findOne('prod1', 'store1');
      expect(result).toEqual(mockProduct);
    });

    it('should throw NotFoundException if product not found', async () => {
      model.findOne.mockResolvedValue(null);

      await expect(service.findOne('prod1', 'store1')).rejects.toThrow(
        'Product not found',
      );
    });
  });

  describe('findByPublicId', () => {
    it('should return a product by publicId', async () => {
      const mockProduct = {
        _id: 'prod1',
        name: 'Red Dress',
        publicId: 'abc123',
        storeId: { name: 'My Store' },
      };
      model.findOne.mockResolvedValue(mockProduct);

      const result = await service.findByPublicId('abc123');
      expect(result).toEqual(mockProduct);
    });

    it('should throw NotFoundException if product not found by publicId', async () => {
      model.findOne.mockResolvedValue(null);

      await expect(service.findByPublicId('nonexistent')).rejects.toThrow(
        'Product not found',
      );
    });
  });

  describe('update', () => {
    it('should update and return the product', async () => {
      const mockProduct = {
        _id: 'prod1',
        name: 'Updated Dress',
        storeId: 'store1',
      };
      model.findOneAndUpdate.mockResolvedValue(mockProduct);

      const result = await service.update('prod1', 'store1', {
        name: 'Updated Dress',
      });
      expect(result).toEqual(mockProduct);
      expect(model.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: 'prod1', storeId: 'store1' },
        { $set: { name: 'Updated Dress' } },
        { new: true },
      );
    });

    it('should throw NotFoundException if product not found', async () => {
      model.findOneAndUpdate.mockResolvedValue(null);

      await expect(
        service.update('prod1', 'store1', { name: 'Updated' }),
      ).rejects.toThrow('Product not found');
    });
  });

  describe('remove', () => {
    it('should delete and return the product', async () => {
      const mockProduct = {
        _id: 'prod1',
        name: 'Red Dress',
        storeId: 'store1',
      };
      model.findOneAndDelete.mockResolvedValue(mockProduct);

      const result = await service.remove('prod1', 'store1');
      expect(result).toEqual(mockProduct);
      expect(model.findOneAndDelete).toHaveBeenCalledWith({
        _id: 'prod1',
        storeId: 'store1',
      });
    });

    it('should throw NotFoundException if product not found', async () => {
      model.findOneAndDelete.mockResolvedValue(null);

      await expect(service.remove('prod1', 'store1')).rejects.toThrow(
        'Product not found',
      );
    });
  });

  describe('getShareUrl', () => {
    it('should return a share URL for a valid product', async () => {
      model.findOne.mockResolvedValue({ _id: 'prod1', publicId: 'abc123' });

      process.env.FRONTEND_URL = 'https://reselio.com';

      const result = await service.getShareUrl('prod1', 'store1');

      expect(model.findOne).toHaveBeenCalledWith({ _id: 'prod1', storeId: 'store1' });
      expect(result.shareUrl).toBe('https://reselio.com/p/abc123');
    });

    it('should throw NotFoundException if product not found', async () => {
      model.findOne.mockResolvedValue(null);

      await expect(service.getShareUrl('prod1', 'store1')).rejects.toThrow(
        'Product not found',
      );
    });
  });
});
