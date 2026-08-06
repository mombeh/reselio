import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Customer, CustomerDocument } from './schemas/customer.schema';
import { CreateCustomerDto } from './dto/create-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';

@Injectable()
export class CustomersService {
  constructor(
    @InjectModel(Customer.name) private customerModel: Model<CustomerDocument>,
  ) {}

  async create(storeId: string, createCustomerDto: CreateCustomerDto) {
    const customer = new this.customerModel({
      ...createCustomerDto,
      storeId,
    });
    return customer.save();
  }

  async findAllByStore(storeId: string) {
    return this.customerModel.find({ storeId }).sort({ createdAt: -1 });
  }

  async findOne(id: string, storeId: string) {
    const customer = await this.customerModel.findOne({ _id: id, storeId });
    if (!customer) {
      throw new NotFoundException('Customer not found');
    }
    return customer;
  }

  async update(
    id: string,
    storeId: string,
    updateCustomerDto: UpdateCustomerDto,
  ) {
    const customer = await this.customerModel.findOneAndUpdate(
      { _id: id, storeId },
      { $set: updateCustomerDto },
      { new: true },
    );
    if (!customer) {
      throw new NotFoundException('Customer not found');
    }
    return customer;
  }

  async remove(id: string, storeId: string) {
    const customer = await this.customerModel.findOneAndDelete({
      _id: id,
      storeId,
    });
    if (!customer) {
      throw new NotFoundException('Customer not found');
    }
    return customer;
  }
}
