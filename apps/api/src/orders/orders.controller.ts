import {
  Controller,
  UseGuards,
  Post,
  Body,
  Req,
  Get,
  Patch,
  Param,
  Res,
  Delete,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { OrdersService } from './orders.service';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { Query } from '@nestjs/common';
import type { Response } from 'express';
import { GetOrdersQueryDto } from './dto/get-orders-query.dto';
import { CreateCustomerDto } from './dto/create-customer.dto';

@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @UseGuards(AuthGuard('jwt'))
  @Post()
  create(@Body() body: any, @Req() req: any) {
    return this.ordersService.create(body, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get()
  getMyOrders(@Req() req: any, @Query() query: GetOrdersQueryDto) {
    return this.ordersService.findAllByUser(req.user.userId, query);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch(':id/status')
  updateStatus(
    @Param('id') orderId: string,
    @Body() body: UpdateOrderStatusDto,
    @Req() req: any,
  ) {
    return this.ordersService.updateStatus(
      orderId,
      body.status,
      req.user.userId,
    );
  }
  @UseGuards(AuthGuard('jwt'))
  @Get('dashboard')
  getDashboard(@Req() req: any) {
    return this.ordersService.getDashboardMetrics(req.user.userId);
  }
  @UseGuards(AuthGuard('jwt'))
  @Get('customers')
  getCustomers(@Req() req: any) {
    return this.ordersService.getCustomersSummary(req.user.userId);
  }
  @UseGuards(AuthGuard('jwt'))
  @Get('analytics/monthly')
  getMonthlyAnalytics(@Req() req: any) {
    return this.ordersService.getMonthlyAnalytics(req.user.userId);
  }
  @UseGuards(AuthGuard('jwt'))
  @Get('analytics/status')
  getStatusBreakdown(@Req() req: any) {
    return this.ordersService.getStatusBreakdown(req.user.userId);
  }
  @UseGuards(AuthGuard('jwt'))
  @Get('analytics/products')
  getTopProducts(@Req() req: any) {
    return this.ordersService.getTopProducts(req.user.userId);
  }
  @UseGuards(AuthGuard('jwt'))
  @Get('analytics/daily')
  getDailySales(@Req() req: any) {
    return this.ordersService.getDailySales(req.user.userId);
  }
  @UseGuards(AuthGuard('jwt'))
  @Get('analytics/yearly')
  getYearlyAnalytics(@Req() req: any) {
    return this.ordersService.getYearlyAnalytics(req.user.userId);
  }
  @UseGuards(AuthGuard('jwt'))
  @Get('export')
  async exportOrders(@Req() req: any, @Res() res: Response) {
    const csv = await this.ordersService.exportOrders(req.user.userId);

    res.header('Content-Type', 'text/csv');
    res.attachment('orders.csv');
    return res.send(csv);
  }

  // Customer endpoints
  @UseGuards(AuthGuard('jwt'))
  @Post('customers')
  createCustomer(@Body() body: CreateCustomerDto, @Req() req: any) {
    return this.ordersService.createCustomer(body, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('customers/list')
  getAllCustomers(@Req() req: any) {
    return this.ordersService.findAllCustomers(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('customers/:id')
  getCustomerById(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.findCustomerById(id, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch('customers/:id')
  updateCustomer(
    @Param('id') id: string,
    @Body() body: CreateCustomerDto,
    @Req() req: any,
  ) {
    return this.ordersService.updateCustomer(id, body, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete('customers/:id')
  deleteCustomer(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.deleteCustomer(id, req.user.userId);
  }
}
