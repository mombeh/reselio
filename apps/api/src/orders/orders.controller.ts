import { Controller } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { UseGuards, Post, Body, Req, Get } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

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
  getMyOrders(@Req() req: any) {
    return this.ordersService.findAllByUser(req.user.userId);
  }
}
