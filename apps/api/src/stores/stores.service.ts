import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Store, StoreDocument } from './schemas/store.schema';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';

@Injectable()
export class StoresService {
  constructor(
    @InjectModel(Store.name) private storeModel: Model<StoreDocument>,
  ) {}

  async create(storeData: CreateStoreDto, userId: string) {
    const existingStore = await this.storeModel.findOne({ userId });
    if (existingStore) {
      throw new ConflictException('You already have a store');
    }

    const store = new this.storeModel({
      ...storeData,
      userId,
    });
    return store.save();
  }

  async getMyStore(userId: string) {
    const store = await this.storeModel.findOne({ userId });
    if (!store) {
      throw new NotFoundException('Store not found');
    }
    return store;
  }

  async updateStore(userId: string, storeData: UpdateStoreDto) {
    const store = await this.storeModel.findOneAndUpdate(
      { userId },
      { $set: storeData },
      { new: true },
    );
    if (!store) {
      throw new NotFoundException('Store not found');
    }
    return store;
  }

  async getPublicStore(userId: string) {
    const store = await this.storeModel.findOne({ userId });
    if (!store) {
      return null;
    }
    return {
      name: store.name,
      description: store.description,
      phone: store.phone,
      address: store.address,
      logo: store.logo,
    };
  }
}
