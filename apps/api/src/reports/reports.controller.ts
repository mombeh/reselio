import { Controller, Get, UseGuards, Req, Query } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ReportsService } from './reports.service';
import { SalesReportQueryDto } from './dto/sales-report-query.dto';
import { RevenueReportQueryDto } from './dto/revenue-report-query.dto';

@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get('sales')
  getSalesReport(@Req() req: any, @Query() query: SalesReportQueryDto) {
    return this.reportsService.getSalesReport(req.user.userId, query);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('products')
  getProductPerformance(@Req() req: any) {
    return this.reportsService.getProductPerformance(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('customers')
  getCustomerReport(@Req() req: any) {
    return this.reportsService.getCustomerReport(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('revenue')
  getRevenueTrend(@Req() req: any, @Query() query: RevenueReportQueryDto) {
    return this.reportsService.getRevenueTrend(req.user.userId, query);
  }
}
