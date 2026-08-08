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
      role: userData.role ?? Role.Customer,
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
}
