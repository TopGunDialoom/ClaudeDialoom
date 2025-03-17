import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThemeSettings } from './entities/theme-settings.entity';
import { Content } from './entities/content.entity';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { UsersModule } from '../users/users.module';
import { HostsModule } from '../hosts/hosts.module';
import { ReservationsModule } from '../reservations/reservations.module';
import { PaymentsModule } from '../payments/payments.module';
import { GamificationModule } from '../gamification/gamification.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ThemeSettings, Content]),
    UsersModule,
    HostsModule,
    ReservationsModule,
    PaymentsModule,
    GamificationModule,
  ],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
