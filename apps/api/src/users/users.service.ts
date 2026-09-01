import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import * as bcrypt from 'bcrypt';
import { CreateUserDto } from './dto/create-user.dto';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { Role } from '../auth/enums/role.enum';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async create(userData: CreateUserDto) {
    const existingUser = await this.userModel.findOne({
      email: userData.email,
    });
    if (existingUser) {
      throw new ConflictException('Email is already registered');
    }

    const hashedPassword = await bcrypt.hash(userData.password, 10);
    const newUser = new this.userModel({
      ...userData,
      password: hashedPassword,
    });
    return newUser.save();
  }

  async findAll() {
    return this.userModel.find();
  }

  async findByEmail(email: string) {
    return this.userModel.findOne({ email });
  }

  async findById(id: string) {
    return this.userModel.findById(id);
  }

  async validateUser(email: string, password: string) {
    const user = await this.findByEmail(email);
    if (!user) return null;
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) return null;
    return user;
  }

  async createWithGoogle(email: string, name: string, hashedPassword: string) {
    const newUser = new this.userModel({
      email,
      name,
      password: hashedPassword,
      role: Role.Customer,
    });
    return newUser.save();
  }

  async updateProfile(
    userId: string,
    data: {
      name?: string;
      email?: string;
      businessName?: string;
      phone?: string;
      address?: string;
      currency?: string;
      role?: Role;
    },
  ) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    if (data.name) user.name = data.name;
    if (data.email) user.email = data.email;
    if (data.businessName !== undefined) (user as any).businessName = data.businessName;
    if (data.phone !== undefined) (user as any).phone = data.phone;
    if (data.address !== undefined) (user as any).address = data.address;
    if (data.currency !== undefined) (user as any).currency = data.currency;
    if (data.role) user.role = data.role;

    return user.save();
  }

  async updatePassword(
    userId: string,
    currentPassword: string,
    newPassword: string,
  ) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    const isPasswordValid = await bcrypt.compare(
      currentPassword,
      user.password,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    user.password = await bcrypt.hash(newPassword, 10);
    return user.save();
  }

  async findSellers(query: { search?: string; isActive?: boolean; page?: number; limit?: number }) {
    const page = query.page || 1;
    const limit = query.limit || 10;
    const skip = (page - 1) * limit;

    const filter: any = { role: Role.Client };
    if (query.isActive !== undefined) {
      filter.isActive = query.isActive;
    }

    if (query.search && query.search.trim().length > 0) {
      const searchRegex = { $regex: query.search.trim(), $options: 'i' };
      filter.$or = [
        { name: searchRegex },
        { email: searchRegex },
        { phone: searchRegex },
      ];
    }

    const total = await this.userModel.countDocuments(filter);

    const sellers = await this.userModel
      .find(filter)
      .select('-password')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    return {
      data: sellers,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findSellerById(id: string) {
    const seller = await this.userModel.findById(id).select('-password');
    if (!seller) {
      throw new Error('Seller not found');
    }
    return seller;
  }

  async updatePasswordByUserId(userId: string, newPassword: string) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }
    user.password = await bcrypt.hash(newPassword, 10);
    return user.save();
  }

  async toggleSellerStatus(id: string, isActive: boolean) {
    const seller = await this.userModel.findById(id);
    if (!seller) {
      throw new Error('Seller not found');
    }
    if (seller.role !== Role.Client) {
      throw new Error('User is not a seller');
    }

    seller.isActive = isActive;
    return seller.save();
  }
}
