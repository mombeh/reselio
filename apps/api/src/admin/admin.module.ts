import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { DashboardModule } from '../dashboard/dashboard.module';
import { UsersModule } from '../users/users.module';
import { CustomersModule } from '../customers/customers.module';

@Module({
  imports: [DashboardModule, UsersModule, CustomersModule],
  controllers: [AdminController],
})
export class AdminModule {}
