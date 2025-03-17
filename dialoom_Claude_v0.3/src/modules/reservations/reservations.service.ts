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
