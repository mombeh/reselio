import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { DashboardModule } from '../dashboard/dashboard.module';
import { UsersModule } from '../users/users.module';
import { CustomersModule } from '../customers/customers.module';
import { OrdersModule } from '../orders/orders.module';
import { ReportsModule } from '../reports/reports.module';

@Module({
  imports: [DashboardModule, UsersModule, CustomersModule, OrdersModule, ReportsModule],
  controllers: [AdminController],
})
export class AdminModule {}
