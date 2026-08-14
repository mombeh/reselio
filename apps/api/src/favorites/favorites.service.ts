import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Favorite, FavoriteDocument } from './schemas/favorite.schema';
import { Product, ProductDocument } from '../products/schemas/product.schema';

@Injectable()
export class FavoritesService {
  constructor(
    @InjectModel(Favorite.name) private favoriteModel: Model<FavoriteDocument>,
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
  ) {}

  async add(userId: string, productId: string) {
    const existing = await this.favoriteModel.findOne({ userId, productId });
    if (existing) {
      throw new ConflictException('Product is already in favorites');
    }

    const product = await this.productModel.findById(productId);
    if (!product) {
      throw new NotFoundException('Product not found');
    }

    const favorite = new this.favoriteModel({ userId, productId });
    return favorite.save();
  }

  async remove(userId: string, productId: string) {
    const favorite = await this.favoriteModel.findOneAndDelete({ userId, productId });
    if (!favorite) {
      throw new NotFoundException('Favorite not found');
    }
    return favorite;
  }

  async findByUser(userId: string) {
    const favorites = await this.favoriteModel
      .find({ userId })
      .sort({ createdAt: -1 });

    const productIds = favorites.map((f) => f.productId);
    const products = await this.productModel
      .find({ _id: { $in: productIds } })
      .select('name description price quantity category imageUrl publicId');

    const productMap = new Map(products.map((p) => [p._id.toString(), p]));

    return favorites
      .filter((f) => productMap.has(f.productId))
      .map((f) => ({
        _id: f._id,
        productId: f.productId,
        createdAt: (f as any).createdAt,
        product: productMap.get(f.productId),
      }));
  }
}
