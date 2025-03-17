import {
  Controller,
  Get,
  Put,
  Param,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { Notification } from './entities/notification.entity';

@ApiTags('notifications')
@Controller('notifications')
@ApiBearerAuth()
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all notifications for current user' })
  findAll(@Req() req): Promise<Notification[]> {
    return this.notificationsService.findByUser(req.user.id);
  }

  @Get('unread')
  @ApiOperation({ summary: 'Get unread notifications for current user' })
  findUnread(@Req() req): Promise<Notification[]> {
    return this.notificationsService.findUnreadByUser(req.user.id);
  }

  @Put(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  markAsRead(@Param('id') id: string): Promise<Notification> {
    return this.notificationsService.markAsRead(id);
  }

  @Put('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  markAllAsRead(@Req() req): Promise<void> {
    return this.notificationsService.markAllAsRead(req.user.id);
  }
}
