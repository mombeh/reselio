import { Controller, Get, Patch, Param, Body, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get()
  findAll(@Req() req: any) {
    return this.notificationsService.findAllByUser(req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch(':id/read')
  markAsRead(@Param('id') id: string, @Req() req: any) {
    return this.notificationsService.markAsRead(id, req.user.userId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch('read-all')
  markAllAsRead(@Req() req: any) {
    return this.notificationsService.markAllAsRead(req.user.userId);
  }
}
