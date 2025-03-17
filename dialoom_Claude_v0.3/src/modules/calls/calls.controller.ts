import {
  Controller,
  Get,
  Query,
  UseGuards,
  Req,
  BadRequestException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CallsService } from './calls.service';

@ApiTags('calls')
@Controller('calls')
@ApiBearerAuth()
export class CallsController {
  constructor(private readonly callsService: CallsService) {}

  @Get('token')
  @ApiOperation({ summary: 'Generate Agora token for a call' })
  async generateToken(
    @Req() req,
    @Query('reservationId') reservationId: string,
    @Query('role') role: 'host' | 'client',
  ) {
    if (!role || !['host', 'client'].includes(role)) {
      throw new BadRequestException('Invalid role. Must be "host" or "client"');
    }
    
    if (!reservationId) {
      throw new BadRequestException('reservationId is required');
    }
    
    return this.callsService.generateToken(
      reservationId,
      req.user.id,
      role,
    );
  }
}
