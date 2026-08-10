import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { randomBytes } from 'crypto';
import { Product, ProductDocument } from './schemas/product.schema';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { OrderItem, OrderItemDocument } from '../orders/schemas/order-item.schema';

@Injectable()
export class ProductsService {
  constructor(
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
    @InjectModel(OrderItem.name) private orderItemModel: Model<OrderItemDocument>,
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
}
