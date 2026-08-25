import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { randomBytes } from 'crypto';
import { Product, ProductDocument } from './schemas/product.schema';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { OrderItem, OrderItemDocument } from '../orders/schemas/order-item.schema';
import { Store, StoreDocument } from '../stores/schemas/store.schema';

@Injectable()
export class ProductsService {
  constructor(
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
    @InjectModel(OrderItem.name) private orderItemModel: Model<OrderItemDocument>,
    @InjectModel(Store.name) private storeModel: Model<StoreDocument>,
  ) {}

  private generatePublicId(): string {
    return randomBytes(6).toString('hex');
  }

  async create(storeId: string, createProductDto: CreateProductDto) {
    const publicId = this.generatePublicId();
    const product = new this.productModel({
      ...createProductDto,
      storeId,
      publicId,
    });
    return product.save();
  }

  async findAllByStore(storeId: string, search?: string, category?: string) {
    const filter: Record<string, unknown> = { storeId };

    if (category && category.length > 0) {
      filter.category = category;
    }

    if (search && search.length > 0) {
      filter.name = { $regex: search, $options: 'i' };
    }

    return this.productModel.find(filter).sort({ createdAt: -1 });
  }

  async findAll(search?: string, category?: string) {
    const filter: Record<string, unknown> = {};

    if (category && category.length > 0) {
      filter.category = category;
    }

    if (search && search.length > 0) {
      filter.name = { $regex: search, $options: 'i' };
    }

    return this.productModel.find(filter).sort({ createdAt: -1 });
  }

  async findOne(id: string, storeId: string) {
    const product = await this.productModel.findOne({ _id: id, storeId });
    if (!product) {
      throw new NotFoundException('Product not found');
    }
    return product;
  }

  async findByPublicId(publicId: string) {
    const product = await this.productModel.findOne({ publicId });
    if (!product) {
      throw new NotFoundException('Product not found');
    }
    return product;
  }

  async update(
    id: string,
    storeId: string,
    updateProductDto: UpdateProductDto,
  ) {
    const product = await this.productModel.findOneAndUpdate(
      { _id: id, storeId },
      { $set: updateProductDto },
      { new: true },
    );
    if (!product) {
      throw new NotFoundException('Product not found');
    }
    return product;
  }

  async remove(id: string, storeId: string) {
    const product = await this.productModel.findOneAndDelete({
      _id: id,
      storeId,
    });
    if (!product) {
      throw new NotFoundException('Product not found');
    }

    const hasOrders = await this.orderItemModel.findOne({ productId: id });
    if (hasOrders) {
      throw new ConflictException(
        'Cannot delete product that is associated with existing orders',
      );
    }

    return product;
  }

  async getShareUrl(productId: string, storeId: string) {
    const product = await this.productModel.findOne({ _id: productId, storeId });
    if (!product) {
      throw new NotFoundException('Product not found');
    }

    if (!product.publicId) {
      product.publicId = this.generatePublicId();
      await product.save();
    }

    const baseUrl = process.env.FRONTEND_URL || 'http://localhost:4000';
    return {
      shareUrl: `${baseUrl}/p/${product.publicId}`,
    };
  }

  getStockStatus(quantity: number): string {
    if (quantity <= 0) return 'Out of Stock';
    if (quantity < 5) return 'Low Stock';
    return 'In Stock';
  }

  async findAllPublic(search?: string, category?: string) {
    const filter: Record<string, unknown> = {};

    if (category && category.length > 0) {
      filter.category = category;
    }

    if (search && search.length > 0) {
      filter.name = { $regex: search, $options: 'i' };
    }

    const products = await this.productModel.find(filter).sort({ createdAt: -1 });

    const storeIds = [...new Set(products.map((p) => p.storeId))];
    const stores = await this.storeModel
      .find({ userId: { $in: storeIds } })
      .select('name address phone logo description');

    const storeMap = new Map(stores.map((s) => [s.userId, s]));

    return products.map((p) => {
      const store = storeMap.get(p.storeId);
      return {
        _id: p._id,
        storeId: p.storeId,
        name: p.name,
        description: p.description,
        price: p.price,
        quantity: p.quantity,
        category: p.category,
        imageUrl: p.imageUrl,
        publicId: p.publicId,
        storeName: store?.name || null,
        storeAddress: store?.address || null,
        storePhone: store?.phone || null,
        storeLogo: store?.logo || null,
        availability: this.getStockStatus(p.quantity),
      };
    });
  }
}
