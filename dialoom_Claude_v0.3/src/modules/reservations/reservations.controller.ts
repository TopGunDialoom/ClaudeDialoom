import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReservationsService } from './reservations.service';
import { Reservation, ReservationStatus } from './entities/reservation.entity';
import { Availability, RecurrenceType } from './entities/availability.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('reservations')
@Controller('reservations')
@ApiBearerAuth()
export class ReservationsController {
  constructor(private readonly reservationsService: ReservationsService) {}

  @Get()
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get all reservations (admin only)' })
  findAll() {
    return this.reservationsService.findAll();
  }

  @Get('me')
  @ApiOperation({ summary: 'Get current user reservations' })
  findUserReservations(@Req() req) {
    return this.reservationsService.findByUser(req.user.id);
  }

  @Get('host')
  @ApiOperation({ summary: 'Get host reservations' })
  findHostReservations(@Req() req) {
    return this.reservationsService.findByHost(req.user.id);
  }

  @Get('upcoming')
  @ApiOperation({ summary: 'Get upcoming reservations' })
  findUpcoming(@Req() req, @Query('isHost') isHost: boolean) {
    return this.reservationsService.findUpcoming(req.user.id, isHost);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get reservation by ID' })
  findOne(@Param('id') id: string) {
    return this.reservationsService.findById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new reservation' })
  create(
    @Req() req,
    @Body() reservationData: {
      hostId: string;
      startTime: Date;
      endTime: Date;
      amount: number;
    },
  ) {
    return this.reservationsService.create(
      req.user.id,
      reservationData.hostId,
      new Date(reservationData.startTime),
      new Date(reservationData.endTime),
      reservationData.amount,
    );
  }

  @Put(':id/status')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Update reservation status (admin only)' })
  updateStatus(
    @Param('id') id: string,
    @Body() data: { status: ReservationStatus; reason?: string },
  ) {
    return this.reservationsService.updateStatus(id, data.status, data.reason);
  }

  @Put(':id/cancel')
  @ApiOperation({ summary: 'Cancel a reservation' })
  cancel(
    @Req() req,
    @Param('id') id: string,
    @Body('reason') reason: string,
  ) {
    return this.reservationsService.cancel(id, req.user.id, reason);
  }

  @Put(':id/reschedule')
  @ApiOperation({ summary: 'Reschedule a reservation' })
  reschedule(
    @Req() req,
    @Param('id') id: string,
    @Body() data: { startTime: Date; endTime: Date },
  ) {
    return this.reservationsService.reschedule(
      id,
      req.user.id,
      new Date(data.startTime),
      new Date(data.endTime),
    );
  }

  @Put(':id/complete')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Mark a reservation as completed (admin only)' })
  complete(@Param('id') id: string) {
    return this.reservationsService.complete(id);
  }

  // Host availability management
  @Post('availability')
  @ApiOperation({ summary: 'Create host availability' })
  createAvailability(
    @Req() req,
    @Body() data: {
      startTime: Date;
      endTime: Date;
      recurrenceType?: RecurrenceType;
      daysOfWeek?: string[];
    },
  ) {
    return this.reservationsService.createAvailability(
      req.user.id,
      new Date(data.startTime),
      new Date(data.endTime),
      data.recurrenceType,
      data.daysOfWeek,
    );
  }

  @Get('availability/:hostId')
  @ApiOperation({ summary: 'Get host availability' })
  getHostAvailability(
    @Param('hostId') hostId: string,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    return this.reservationsService.getHostAvailability(
      hostId,
      new Date(startDate),
      new Date(endDate),
    );
  }
}
