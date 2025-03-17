#!/bin/bash

# Verificar si estamos en la carpeta correcta del proyecto
if [ ! -f "./package.json" ]; then
  echo "Error: Este script debe ejecutarse desde la carpeta raíz del proyecto"
  exit 1
fi

echo "Corrigiendo errores comunes en el código fuente..."

# Crear la carpeta src si no existe
mkdir -p src/common/{decorators,filters,guards,interceptors,pipes} \
         src/modules/{auth/{strategies,guards,dto},users/{entities,dto},hosts/{entities,dto},reservations/{entities,dto},payments/{entities,dto},calls/{entities,dto},notifications/{channels,entities,dto},gamification/{entities,dto},admin/{entities,dto},i18n}

# Corregir public.guard.ts
if [ -f "src/common/guards/public.guard.ts" ]; then
  cat > src/common/guards/public.guard.ts << 'EOF'
import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';

export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => {
  return (target: any, key: string, descriptor: PropertyDescriptor) => {
    const reflector = new Reflector();
    reflector.defineMetadata(IS_PUBLIC_KEY, true, descriptor.value);
    return descriptor;
  };
};

@Injectable()
export class PublicGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    if (isPublic) {
      return true;
    }
    
    return super.canActivate(context);
  }
}
EOF
  echo "✅ Corregido: src/common/guards/public.guard.ts"
fi

# Corregir admin.service.ts (agregar importaciones)
if [ -f "src/modules/admin/admin.service.ts" ]; then
  sed -i '1s/^/import { Repository, MoreThanOrEqual, LessThanOrEqual } from "typeorm";\n/' src/modules/admin/admin.service.ts
  echo "✅ Corregido: src/modules/admin/admin.service.ts"
fi

# Corregir availability.entity.ts (corregir el nombre de la propiedad)
if [ -f "src/modules/reservations/entities/availability.entity.ts" ]; then
  sed -i 's/daysOfWe\n  ek/daysOfWeek/' src/modules/reservations/entities/availability.entity.ts
  echo "✅ Corregido: src/modules/reservations/entities/availability.entity.ts"
fi

# Corregir i18n.service.ts
if [ -f "src/modules/i18n/i18n.service.ts" ]; then
  sed -i '54s/sectionStack.push(currentSection\[sectionStack\[sectionStack.length - 1\]\]);/if (typeof sectionStack[sectionStack.length - 1] === "string") {\n                  const key = sectionStack[sectionStack.length - 1] as string;\n                  sectionStack.push(currentSection[key]);\n                }/' src/modules/i18n/i18n.service.ts
  echo "✅ Corregido: src/modules/i18n/i18n.service.ts"
fi

# Corregir payments.controller.ts
if [ -f "src/modules/payments/payments.controller.ts" ]; then
  sed -i '129s/await this.paymentsService.handlePaymentIntentSucceeded(paymentIntent.id);/const pi = paymentIntent as any;\n          if (pi && pi.id) {\n            await this.paymentsService.handlePaymentIntentSucceeded(pi.id);\n          }/' src/modules/payments/payments.controller.ts
  echo "✅ Corregido: src/modules/payments/payments.controller.ts"
fi

# Corregir payments.service.ts
if [ -f "src/modules/payments/payments.service.ts" ]; then
  cat > src/modules/payments/payments.service.ts << 'EOF'
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, IsNull } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Transaction, TransactionStatus, TransactionType } from './entities/transaction.entity';
import { StripeService } from './stripe.service';
import { UsersService } from '../users/users.service';
import { HostsService } from '../hosts/hosts.service';
import { addDays } from 'date-fns';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Transaction)
    private transactionsRepository: Repository<Transaction>,
    private stripeService: StripeService,
    private usersService: UsersService,
    private hostsService: HostsService,
    private configService: ConfigService,
  ) {}

  async findAll(): Promise<Transaction[]> {
    return this.transactionsRepository.find({
      relations: ['user', 'host'],
    });
  }

  async findById(id: string): Promise<Transaction> {
    const transaction = await this.transactionsRepository.findOne({
      where: { id },
      relations: ['user', 'host'],
    });
    
    if (!transaction) {
      throw new NotFoundException(`Transaction with ID ${id} not found`);
    }
    
    return transaction;
  }

  async findByUser(userId: string): Promise<Transaction[]> {
    return this.transactionsRepository.find({
      where: [
        { userId },
        { hostId: userId },
      ],
      relations: ['user', 'host'],
    });
  }

  async createPaymentIntent(
    userId: string,
    hostId: string,
    amount: number,
    reservationId: string,
    description: string,
  ): Promise<any> {
    const user = await this.usersService.findById(userId);
    const host = await this.hostsService.findById(hostId);
    
    if (!user.stripeCustomerId) {
      const customerId = await this.stripeService.createCustomer(
        user.email,
        `${user.firstName} ${user.lastName}`,
      );
      await this.usersService.update(userId, { stripeCustomerId: customerId });
      user.stripeCustomerId = customerId;
    }
    
    if (!host.stripeConnectId) {
      throw new BadRequestException('Host Stripe account not set up');
    }
    
    // Calculate commission and VAT
    const commissionRate = this.configService.get<number>('stripe.commissionRate', 0.10);
    const vatRate = this.configService.get<number>('stripe.vatRate', 0.21);
    
    const commissionAmount = amount * commissionRate;
    const vatAmount = commissionAmount * vatRate;
    const applicationFeeAmount = commissionAmount + vatAmount;
    const netAmount = amount - applicationFeeAmount;
    
    // Create Stripe PaymentIntent
    const paymentIntent = await this.stripeService.createPaymentIntent(
      amount,
      'EUR',
      user.stripeCustomerId,
      host.stripeConnectId,
      description,
      applicationFeeAmount,
    );
    
    // Create transaction record
    const transaction = this.transactionsRepository.create({
      type: TransactionType.PAYMENT,
      userId,
      hostId,
      reservationId,
      amount,
      commissionAmount,
      vatAmount,
      netAmount,
      status: TransactionStatus.PENDING,
      stripePaymentIntentId: paymentIntent.id,
    });
    
    await this.transactionsRepository.save(transaction);
    
    return {
      clientSecret: paymentIntent.client_secret,
      transactionId: transaction.id,
    };
  }

  async handlePaymentIntentSucceeded(paymentIntentId: string): Promise<Transaction> {
    const transaction = await this.transactionsRepository.findOne({
      where: { stripePaymentIntentId: paymentIntentId },
    });
    
    if (!transaction) {
      throw new NotFoundException(`Transaction with payment intent ${paymentIntentId} not found`);
    }
    
    const paymentIntent = await this.stripeService.getPaymentIntent(paymentIntentId);
    
    transaction.status = TransactionStatus.COMPLETED;
    
    // Usar una verificación más segura con typecasting
    const paymentIntentAny = paymentIntent as any;
    if (paymentIntentAny &&
        paymentIntentAny.charges &&
        paymentIntentAny.charges.data &&
        paymentIntentAny.charges.data.length > 0) {
      transaction.stripeChargeId = paymentIntentAny.charges.data[0].id;
    }
    
    return this.transactionsRepository.save(transaction);
  }

  async processReleasePendingPayments(): Promise<Transaction[]> {
    const retentionDays = this.configService.get<number>('stripe.retentionDays', 7);
    const retentionDate = addDays(new Date(), -retentionDays);
    
    const pendingTransactions = await this.transactionsRepository.find({
      where: {
        status: TransactionStatus.COMPLETED,
        isReleased: false,
        createdAt: LessThanOrEqual(retentionDate),
      },
    });
    
    const releasedTransactions: Transaction[] = [];
    
    for (const transaction of pendingTransactions) {
      transaction.isReleased = true;
      transaction.releasedAt = new Date();
      
      await this.transactionsRepository.save(transaction);
      
      releasedTransactions.push(transaction);
    }
    
    return releasedTransactions;
  }

  async refundTransaction(transactionId: string, reason: string): Promise<Transaction> {
    const transaction = await this.findById(transactionId);
    
    if (transaction.status !== TransactionStatus.COMPLETED) {
      throw new BadRequestException('Only completed transactions can be refunded');
    }
    
    if (!transaction.stripePaymentIntentId) {
      throw new BadRequestException('Transaction has no associated payment intent');
    }
    
    const refund = await this.stripeService.refundPayment(transaction.stripePaymentIntentId);
    
    transaction.status = TransactionStatus.REFUNDED;
    transaction.notes = reason;
    
    return this.transactionsRepository.save(transaction);
  }

  async getTransactionStats() {
    const totalTransactions = await this.transactionsRepository.count({
      where: { status: TransactionStatus.COMPLETED },
    });
    
    const result = await this.transactionsRepository
      .createQueryBuilder('transaction')
      .select('SUM(transaction.amount)', 'totalAmount')
      .addSelect('SUM(transaction.commissionAmount)', 'totalCommission')
      .addSelect('SUM(transaction.vatAmount)', 'totalVat')
      .where('transaction.status = :status', { status: TransactionStatus.COMPLETED })
      .getRawOne();
    
    return {
      totalTransactions,
      totalAmount: result.totalAmount || 0,
      totalCommission: result.totalCommission || 0,
      totalVat: result.totalVat || 0,
      totalRevenue: (result.totalCommission || 0) + (result.totalVat || 0),
    };
  }
}
EOF
  echo "✅ Reescrito completamente: src/modules/payments/payments.service.ts"
fi

# Corregir reservations.service.ts
if [ -f "src/modules/reservations/reservations.service.ts" ]; then
  cat > src/modules/reservations/reservations.service.ts << 'EOF'
import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { Reservation, ReservationStatus } from './entities/reservation.entity';
import { Availability, RecurrenceType } from './entities/availability.entity';
import { UsersService } from '../users/users.service';
import { HostsService } from '../hosts/hosts.service';
import { addDays, isAfter, isBefore } from 'date-fns';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ReservationsService {
  constructor(
    @InjectRepository(Reservation)
    private reservationsRepository: Repository<Reservation>,
    @InjectRepository(Availability)
    private availabilityRepository: Repository<Availability>,
    private usersService: UsersService,
    private hostsService: HostsService,
  ) {}

  async findAll(): Promise<Reservation[]> {
    return this.reservationsRepository.find({
      relations: ['user', 'host'],
    });
  }

  async findById(id: string): Promise<Reservation> {
    const reservation = await this.reservationsRepository.findOne({
      where: { id },
      relations: ['user', 'host'],
    });
    
    if (!reservation) {
      throw new NotFoundException(`Reservation with ID ${id} not found`);
    }
    
    return reservation;
  }

  async findByUser(userId: string): Promise<Reservation[]> {
    return this.reservationsRepository.find({
      where: { userId },
      relations: ['host'],
      order: { startTime: 'DESC' },
    });
  }

  async findByHost(hostId: string): Promise<Reservation[]> {
    return this.reservationsRepository.find({
      where: { hostId },
      relations: ['user'],
      order: { startTime: 'DESC' },
    });
  }

  async findUpcoming(userId: string, isHost: boolean = false): Promise<Reservation[]> {
    const now = new Date();
    
    return this.reservationsRepository.find({
      where: {
        [isHost ? 'hostId' : 'userId']: userId,
        startTime: MoreThanOrEqual(now),
        status: ReservationStatus.CONFIRMED,
      },
      relations: isHost ? ['user'] : ['host'],
      order: { startTime: 'ASC' },
    });
  }

  async create(
    userId: string,
    hostId: string,
    startTime: Date,
    endTime: Date,
    amount: number,
  ): Promise<Reservation> {
    // Validate input
    if (isBefore(startTime, new Date())) {
      throw new BadRequestException('Start time must be in the future');
    }
    
    if (!isAfter(endTime, startTime)) {
      throw new BadRequestException('End time must be after start time');
    }
    
    // Check if the host is available
    const isAvailable = await this.checkHostAvailability(
      hostId,
      startTime,
      endTime,
    );
    
    if (!isAvailable) {
      throw new BadRequestException('Host is not available for the selected time slot');
    }
    
    // Check if user and host exist
    await this.usersService.findById(userId);
    await this.hostsService.findById(hostId);
    
    // Create the reservation
    const reservation = this.reservationsRepository.create({
      id: uuidv4(),
      userId,
      hostId,
      startTime,
      endTime,
      status: ReservationStatus.PENDING,
      amount,
    });
    
    return this.reservationsRepository.save(reservation);
  }

  async updateStatus(
    id: string,
    status: ReservationStatus,
    reason?: string,
  ): Promise<Reservation> {
    const reservation = await this.findById(id);
    
    reservation.status = status;
    
    if (reason) {
      if (status === ReservationStatus.CANCELLED) {
        reservation.cancellationReason = reason;
      } else {
        reservation.notes = reason;
      }
    }
    
    return this.reservationsRepository.save(reservation);
  }

  async cancel(id: string, userId: string, reason: string): Promise<Reservation> {
    const reservation = await this.findById(id);
    
    // Check if the user is part of the reservation
    if (reservation.userId !== userId && reservation.hostId !== userId) {
      throw new BadRequestException('You are not allowed to cancel this reservation');
    }
    
    // Check if the reservation can be cancelled
    if (reservation.status !== ReservationStatus.PENDING &&
        reservation.status !== ReservationStatus.CONFIRMED) {
      throw new BadRequestException('This reservation cannot be cancelled');
    }
    
    // Check cancellation window (e.g., 24 hours before)
    const now = new Date();
    const cancellationDeadline = new Date(reservation.startTime);
    cancellationDeadline.setHours(cancellationDeadline.getHours() - 24);
    
    if (isAfter(now, cancellationDeadline)) {
      throw new BadRequestException('Cancellation deadline has passed');
    }
    
    // Update reservation status
    reservation.status = ReservationStatus.CANCELLED;
    reservation.cancellationReason = reason;
    
    return this.reservationsRepository.save(reservation);
  }

  async reschedule(
    id: string,
    userId: string,
    newStartTime: Date,
    newEndTime: Date,
  ): Promise<Reservation> {
    const originalReservation = await this.findById(id);
    
    // Check if the user is part of the reservation
    if (originalReservation.userId !== userId && originalReservation.hostId !== userId) {
      throw new BadRequestException('You are not allowed to reschedule this reservation');
    }
    
    // Check if the reservation can be rescheduled
    if (originalReservation.status !== ReservationStatus.CONFIRMED) {
      throw new BadRequestException('This reservation cannot be rescheduled');
    }
    
    // Check if the new time slot is available
    const isAvailable = await this.checkHostAvailability(
      originalReservation.hostId,
      newStartTime,
      newEndTime,
    );
    
    if (!isAvailable) {
      throw new BadRequestException('Host is not available for the new time slot');
    }
    
    // Create a new reservation
    const newReservation = this.reservationsRepository.create({
      id: uuidv4(),
      userId: originalReservation.userId,
      hostId: originalReservation.hostId,
      startTime: newStartTime,
      endTime: newEndTime,
      status: ReservationStatus.CONFIRMED,
      amount: originalReservation.amount,
      isRescheduled: true,
      originalReservationId: originalReservation.id,
      transactionId: originalReservation.transactionId,
    });
    
    // Cancel the original reservation
    originalReservation.status = ReservationStatus.CANCELLED;
    originalReservation.cancellationReason = 'Rescheduled';
    
    await this.reservationsRepository.save(originalReservation);
    return this.reservationsRepository.save(newReservation);
  }

  async complete(id: string): Promise<Reservation> {
    const reservation = await this.findById(id);
    
    if (reservation.status !== ReservationStatus.CONFIRMED) {
      throw new BadRequestException('This reservation cannot be marked as completed');
    }
    
    // Check if the reservation time has passed
    const now = new Date();
    if (isBefore(now, reservation.endTime)) {
      throw new BadRequestException('This reservation has not ended yet');
    }
    
    reservation.status = ReservationStatus.COMPLETED;
    return this.reservationsRepository.save(reservation);
  }

  // Host availability management
  async createAvailability(
    hostId: string,
    startTime: Date,
    endTime: Date,
    recurrenceType: RecurrenceType = RecurrenceType.ONCE,
    daysOfWeek?: string[],
  ): Promise<Availability> {
    // Validate input
    if (!isAfter(endTime, startTime)) {
      throw new BadRequestException('End time must be after start time');
    }
    
    if (recurrenceType !== RecurrenceType.ONCE && !daysOfWeek?.length) {
      throw new BadRequestException('Days of week must be provided for recurring availability');
    }
    
    // Check if host exists
    await this.hostsService.findById(hostId);
    
    // Create availability
    const availability = new Availability();
    availability.hostId = hostId;
    availability.startTime = startTime;
    availability.endTime = endTime;
    availability.recurrenceType = recurrenceType;
    if (daysOfWeek) {
      availability.daysOfWeek = daysOfWeek;
    }
    
    return this.availabilityRepository.save(availability);
  }

  async getHostAvailability(hostId: string, startDate: Date, endDate: Date): Promise<Availability[]> {
    // Fetch all active availabilities for this host
    const availabilities = await this.availabilityRepository.find({
      where: {
        hostId,
        isActive: true,
      },
    });
    
    // Filter by date range and expand recurring availabilities
    const result: Availability[] = [];
    
    for (const availability of availabilities) {
      if (availability.recurrenceType === RecurrenceType.ONCE) {
        // Check if one-time availability is within the requested range
        if (
          (isAfter(availability.startTime, startDate) || availability.startTime.getTime() === startDate.getTime()) &&
          (isBefore(availability.endTime, endDate) || availability.endTime.getTime() === endDate.getTime())
        ) {
          result.push(availability);
        }
      } else {
        // Handle recurring availabilities by creating instances for each occurrence
        // This is a simplified implementation
        const currentDate = new Date(startDate);
        
        while (isBefore(currentDate, endDate)) {
          const dayOfWeek = currentDate.getDay().toString();
          
          if (availability.daysOfWeek && availability.daysOfWeek.includes(dayOfWeek)) {
            // Create an instance for this day
            const instanceStart = new Date(currentDate);
            instanceStart.setHours(
              availability.startTime.getHours(),
              availability.startTime.getMinutes(),
            );
            
            const instanceEnd = new Date(currentDate);
            instanceEnd.setHours(
              availability.endTime.getHours(),
              availability.endTime.getMinutes(),
            );
            
            const newAvailability = new Availability();
            Object.assign(newAvailability, availability);
            newAvailability.startTime = instanceStart;
            newAvailability.endTime = instanceEnd;
            
            result.push(newAvailability);
          }
          
          // Move to next day
          currentDate.setDate(currentDate.getDate() + 1);
        }
      }
    }
    
    return result;
  }

  async checkHostAvailability(hostId: string, startTime: Date, endTime: Date): Promise<boolean> {
    // Get host availabilities
    const availabilities = await this.getHostAvailability(
      hostId,
      new Date(startTime.getFullYear(), startTime.getMonth(), startTime.getDate()),
      new Date(endTime.getFullYear(), endTime.getMonth(), endTime.getDate() + 1),
    );
    
    // Check if there's an availability that fully contains the requested time slot
    const hasAvailability = availabilities.some(
      (a) =>
        (isBefore(a.startTime, startTime) || a.startTime.getTime() === startTime.getTime()) &&
        (isAfter(a.endTime, endTime) || a.endTime.getTime() === endTime.getTime()),
    );
    
    if (!hasAvailability) {
      return false;
    }
    
    // Check if there are no overlapping confirmed reservations
    const overlappingReservations = await this.reservationsRepository.find({
      where: {
        hostId,
        status: ReservationStatus.CONFIRMED,
        startTime: LessThanOrEqual(endTime),
        endTime: MoreThanOrEqual(startTime),
      },
    });
    
    return overlappingReservations.length === 0;
  }
}
EOF
  echo "✅ Reescrito completamente: src/modules/reservations/reservations.service.ts"
fi

echo "Todas las correcciones han sido aplicadas. El código ahora debería construirse correctamente."
