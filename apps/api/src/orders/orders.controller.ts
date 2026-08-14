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
  Query,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { GetOrdersQueryDto } from './dto/get-orders-query.dto';
import { CustomersService } from '../customers/customers.service';
import { CreateCustomerDto } from '../customers/dto/create-customer.dto';
import type { Response } from 'express';

@Controller('orders')
export class OrdersController {
  constructor(
    private readonly ordersService: OrdersService,
    private readonly customersService: CustomersService,
  ) {}

  @UseGuards(AuthGuard('jwt'))
  @Post()
  create(@Body() createOrderDto: CreateOrderDto, @Req() req: any) {
    return this.ordersService.create(req.user.userId, createOrderDto);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get()
  getAllOrders(@Req() req: any, @Query() query: GetOrdersQueryDto) {
    return this.ordersService.findAllByStore(req.user.userId, query);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('dashboard')
  getDashboard(@Req() req: any) {
    return this.ordersService.getDashboardMetrics(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('analytics/daily')
  getDailySales(@Req() req: any, @Query('days') days?: string) {
    const daysNum = days ? parseInt(days, 10) : 30;
    return this.ordersService.getDailySales(req.user.userId, daysNum);
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
  @Get('analytics/yearly')
  getYearlyAnalytics(@Req() req: any) {
    return this.ordersService.getYearlyAnalytics(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('customers')
  getCustomers(@Req() req: any) {
    return this.ordersService.getCustomersSummary(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('customers/list')
  getAllCustomers(@Req() req: any) {
    return this.customersService.findAllByStore(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('customer/:customerId')
  getCustomerOrders(
    @Param('customerId') customerId: string,
    @Req() req: any,
    @Query() query: GetOrdersQueryDto,
  ) {
    return this.ordersService.findAllByCustomer(req.user.userId, customerId, query);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('export')
  async exportOrders(@Req() req: any, @Res() res: Response) {
    const csv = await this.ordersService.exportOrders(req.user.userId);

    res.header('Content-Type', 'text/csv');
    res.attachment('orders.csv');
    return res.send(csv);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('my-orders')
  getMyOrders(@Req() req: any, @Query() query: GetOrdersQueryDto) {
    return this.ordersService.findMyOrders(req.user.userId, query);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get(':id')
  findOne(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.findOne(id, req.user.userId);
  }
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
  @Get(':id')
  findOne(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.findOne(id, req.user.userId);
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
  @Delete(':id')
  cancelOrder(@Param('id') orderId: string, @Req() req: any) {
    return this.ordersService.cancelOrder(orderId, req.user.userId);
  }

  // Customer endpoints
  @UseGuards(AuthGuard('jwt'))
  @Post('customers')
  createCustomer(@Body() body: CreateCustomerDto, @Req() req: any) {
    return this.customersService.create(req.user.userId, body);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('customers/:id')
  getCustomerById(@Param('id') id: string, @Req() req: any) {
    return this.customersService.findOne(id, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch('customers/:id')
  updateCustomer(
    @Param('id') id: string,
    @Body() body: CreateCustomerDto,
    @Req() req: any,
  ) {
    return this.customersService.update(id, req.user.userId, body);
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete('customers/:id')
  deleteCustomer(@Param('id') id: string, @Req() req: any) {
    return this.customersService.remove(id, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('my-orders')
  getMyOrders(@Req() req: any, @Query() query: GetOrdersQueryDto) {
    return this.ordersService.findMyOrders(req.user.userId, query);
  }
}
