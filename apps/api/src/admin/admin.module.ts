import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { DashboardModule } from '../dashboard/dashboard.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [DashboardModule, UsersModule],
  controllers: [AdminController],
})
export class AdminModule {}
