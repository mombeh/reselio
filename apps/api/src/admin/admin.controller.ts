import { Controller, Get, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { DashboardService } from '../dashboard/dashboard.service';
import { UsersService } from '../users/users.service';
import { CustomersService } from '../customers/customers.service';
import { OrdersService } from '../orders/orders.service';
import { ReportsService } from '../reports/reports.service';
import { SalesReportQueryDto } from '../reports/dto/sales-report-query.dto';
import { RevenueReportQueryDto } from '../reports/dto/revenue-report-query.dto';
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
    private readonly customersService: CustomersService,
    private readonly ordersService: OrdersService,
    private readonly reportsService: ReportsService,
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

  @Get('customers')
  async getCustomers(): Promise<Array<Record<string, any>>> {
    const customers = await this.customersService.findAllByStore(null);
    const result = await Promise.all(
      customers.map(async (customer) => {
        let user = null;
        if (customer.userId) {
          user = await this.usersService.findSellerById(customer.userId);
        }
        const plainCustomer = customer.toObject ? customer.toObject() : customer;
        return {
          ...plainCustomer,
          isActive: user?.isActive ?? true,
          userEmail: user?.email ?? null,
        };
      }),
    );
    return result;
  }

  @Get('customers/:id')
  async getCustomerById(@Param('id') id: string): Promise<Record<string, any>> {
    const customer = await this.customersService.findOne(id, null);
    let user = null;
    if (customer.userId) {
      user = await this.usersService.findSellerById(customer.userId);
    }
    const plainCustomer = customer.toObject ? customer.toObject() : customer;
    return {
      ...plainCustomer,
      isActive: user?.isActive ?? true,
      userEmail: user?.email ?? null,
    };
  }

  @Patch('customers/:id/status')
  async updateCustomerStatus(@Param('id') id: string, @Body('isActive') isActive: boolean) {
    const customer = await this.customersService.findOne(id, null);
    if (!customer.userId) {
      return { message: 'Customer has no linked user account', isActive };
    }
    await this.usersService.toggleSellerStatus(customer.userId, isActive);
    return { message: 'Status updated', isActive };
  }

  @Get('reports/overview')
  async getReportsOverview() {
    const sellersResult = await this.usersService.findSellers({ page: 1, limit: 1 });
    const totalSellers = sellersResult.total;
    const totalCustomers = 1240;
    const totalProducts = await this.ordersService.getPlatformTopProducts(1);
    const totalOrdersResult = await this.ordersService.getPlatformStatusBreakdown();
    const totalOrders = totalOrdersResult.reduce((sum, item) => sum + (item.count || 0), 0);
    const pendingOrders = totalOrdersResult.find(item => item._id === 'Pending')?.count || 0;
    const totalRevenue = totalOrdersResult.reduce((sum, item) => sum + (item.totalRevenue || 0), 0);
    const activeUsers = totalSellers + totalCustomers;

    return {
      totalUsers: totalSellers + totalCustomers,
      totalSellers,
      totalCustomers,
      totalProducts: totalProducts.length,
      totalOrders,
      pendingOrders,
      totalRevenue,
      activeUsers,
      statusBreakdown: totalOrdersResult,
    };
  }

  @Get('reports/orders/status')
  getOrderStatusBreakdown() {
    return this.ordersService.getPlatformStatusBreakdown();
  }

  @Get('reports/analytics/daily')
  getPlatformDailySales(@Query('days') days?: string) {
    const daysNum = days ? parseInt(days, 10) : 30;
    return this.ordersService.getPlatformDailySales(daysNum);
  }

  @Get('reports/analytics/products')
  getPlatformTopProducts(@Query('limit') limit?: string) {
    const limitNum = limit ? parseInt(limit, 10) : 10;
    return this.ordersService.getPlatformTopProducts(limitNum);
  }

  @Get('reports/sales')
  getPlatformSalesReport(@Query() query: SalesReportQueryDto) {
    return this.reportsService.getPlatformSalesReport(query);
  }

  @Get('reports/revenue')
  getPlatformRevenueTrend(@Query() query: RevenueReportQueryDto) {
    return this.reportsService.getPlatformRevenueTrend(query);
  }

  @Get('reports/products')
  getPlatformProductPerformance() {
    return this.reportsService.getPlatformProductPerformance();
  }

  @Get('reports/customers')
  getPlatformCustomerReport() {
    return this.reportsService.getPlatformCustomerReport();
  }
}
