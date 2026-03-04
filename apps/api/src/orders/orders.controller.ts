import {
  Controller,
  UseGuards,
  Post,
  Body,
  Req,
  Get,
  Patch,
  Param,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { OrdersService } from './orders.service';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
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
}
