import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { Order, OrderSchema } from '../orders/schemas/order.schema';
import {
  OrderItem,
  OrderItemSchema,
} from '../orders/schemas/order-item.schema';
import { Product, ProductSchema } from '../products/schemas/product.schema';
import { Customer, CustomerSchema } from '../customers/schemas/customer.schema';
import { OrdersModule } from '../orders/orders.module';
import { ProductsModule } from '../products/products.module';
import { CustomersModule } from '../customers/customers.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Order.name, schema: OrderSchema },
      { name: OrderItem.name, schema: OrderItemSchema },
      { name: Product.name, schema: ProductSchema },
      { name: Customer.name, schema: CustomerSchema },
    ]),
    OrdersModule,
    ProductsModule,
    CustomersModule,
  ],
  controllers: [DashboardController],
  providers: [DashboardService],
  exports: [DashboardService],
})
export class DashboardModule {}
