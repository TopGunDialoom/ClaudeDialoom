import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';
import { ReservationsService } from '../reservations/reservations.service';

@Injectable()
export class CallsService {
  constructor(
    private configService: ConfigService,
    private reservationsService: ReservationsService,
  ) {}

  async generateToken(
    reservationId: string,
    userId: string,
    role: 'host' | 'client',
  ): Promise<{ token: string; channelName: string; uid: number; appId: string }> {
    const reservation = await this.reservationsService.findById(reservationId);
    
    if (!reservation) {
      throw new NotFoundException('Reservation not found');
    }
    
    // Check if user is part of the reservation
    const isParticipant =
      userId === reservation.userId || userId === reservation.hostId;
    
    if (!isParticipant) {
      throw new BadRequestException('User is not part of this reservation');
    }
    
    // Check if it's time for the call
    const now = new Date();
    const sessionStart = new Date(reservation.startTime);
    const sessionEnd = new Date(reservation.endTime);
    
    // Allow joining 10 minutes before the session
    const earlyJoinWindow = new Date(sessionStart);
    earlyJoinWindow.setMinutes(earlyJoinWindow.getMinutes() - 10);
    
    if (now < earlyJoinWindow && userId !== reservation.hostId) {
      throw new BadRequestException('Too early to join this call');
    }
    
    if (now > sessionEnd) {
      throw new BadRequestException('This session has already ended');
    }
    
    // Create a unique channel name based on the reservation ID
    const channelName = `dialoom-session-${reservationId}`;
    
    // Generate a UID for the user (could be stored in a real application)
    const uid = role === 'host'
      ? parseInt(reservation.hostId.replace(/\D/g, '').slice(-6), 10) % 100000
      : parseInt(reservation.userId.replace(/\D/g, '').slice(-6), 10) % 100000;
    
    // Get Agora credentials from config
    const appId = this.configService.get<string>('AGORA_APP_ID');
    const appCertificate = this.configService.get<string>('AGORA_APP_CERTIFICATE');
    
    if (!appId || !appCertificate) {
      throw new BadRequestException('Agora credentials not configured');
    }
    
    // Set token expiration (2 hours from now)
    const expirationTimeInSeconds = 7200;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
    
    // Build token
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      role === 'host' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER,
      privilegeExpiredTs,
    );
    
    return {
      token,
      channelName,
      uid,
      appId,
    };
  }
}
