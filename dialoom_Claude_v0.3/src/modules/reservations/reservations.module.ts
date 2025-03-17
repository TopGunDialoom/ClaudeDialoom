import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Reservation } from './entities/reservation.entity';
import { Availability } from './entities/availability.entity';
import { ReservationsService } from './reservations.service';
import { ReservationsController } from './reservations.controller';
import { UsersModule } from '../users/users.module';
import { HostsModule } from '../hosts/hosts.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Reservation, Availability]),
    UsersModule,
    HostsModule,
  ],
  controllers: [ReservationsController],
  providers: [ReservationsService],
  exports: [ReservationsService],
})
export class ReservationsModule {}
