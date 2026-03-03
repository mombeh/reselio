import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import * as bcrypt from 'bcrypt';
import { CreateUserDto } from './dto/create-user.dto';
import { ConflictException } from '@nestjs/common';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}


async create(userData: CreateUserDto) {
  const existingUser = await this.userModel.findOne({ email: userData.email });
  if (existingUser) {
    throw new ConflictException('Email is already registered');
  }

  const hashedPassword = await bcrypt.hash(userData.password, 10);
  const newUser = new this.userModel({ ...userData, password: hashedPassword });
  return newUser.save();
}

  async findAll() {
    return this.userModel.find();
  }

  async findByEmail(email: string) {
    return this.userModel.findOne({ email });
  }

  async validateUser(email: string, password: string) {
    const user = await this.findByEmail(email);
    if (!user) return null;
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) return null;
    return user;
  }
}