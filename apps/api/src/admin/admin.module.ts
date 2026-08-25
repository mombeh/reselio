import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { DashboardModule } from '../dashboard/dashboard.module';
import { UsersModule } from '../users/users.module';
import { CustomersModule } from '../customers/customers.module';
import { OrdersModule } from '../orders/orders.module';
import { ReportsModule } from '../reports/reports.module';
import { ProductsModule } from '../products/products.module';

@Module({
  imports: [DashboardModule, UsersModule, CustomersModule, OrdersModule, ReportsModule, ProductsModule],
  controllers: [AdminController],
})
export class AdminModule {}
