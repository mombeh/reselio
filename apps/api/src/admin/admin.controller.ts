import { Controller, Get, Patch, Body, Param, Query, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { DashboardService } from '../dashboard/dashboard.service';
import { UsersService } from '../users/users.service';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Role } from '../auth/enums/role.enum';

@Controller('admin')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles(Role.Admin)
export class AdminController {
  constructor(
    private readonly dashboardService: DashboardService,
    private readonly usersService: UsersService,
  ) {}

  @Get('dashboard')
  getAdminDashboard() {
    return this.dashboardService.getAdminDashboard();
  }

  @Get('sellers')
  getSellers(
    @Query('search') search?: string,
    @Query('isActive') isActive?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const isActiveBool = isActive !== undefined ? isActive === 'true' : undefined;
    return this.usersService.findSellers({
      search,
      isActive: isActiveBool,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }

  @Get('sellers/:id')
  getSellerById(@Param('id') id: string) {
    return this.usersService.findSellerById(id);
  }

  @Patch('sellers/:id/status')
  updateSellerStatus(@Param('id') id: string, @Body('isActive') isActive: boolean) {
    return this.usersService.toggleSellerStatus(id, isActive);
  }
}
