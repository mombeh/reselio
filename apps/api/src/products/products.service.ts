import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { randomBytes } from 'crypto';
import { Product, ProductDocument } from './schemas/product.schema';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
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

  async findAllByStore(storeId: string) {
    return this.productModel.find({ storeId }).sort({ createdAt: -1 });
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
    return product;
  }

  async getShareUrl(productId: string, storeId: string) {
    const product = await this.productModel.findOne({ _id: productId, storeId });
    if (!product) {
      throw new NotFoundException('Product not found');
    }

    const baseUrl = process.env.FRONTEND_URL || 'http://localhost:4000';
    return {
      shareUrl: `${baseUrl}/p/${product.publicId}`,
    };
  }
}
