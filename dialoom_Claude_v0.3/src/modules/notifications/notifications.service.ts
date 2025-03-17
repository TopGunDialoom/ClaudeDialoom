import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Notification,
  NotificationType,
  NotificationChannel,
} from './entities/notification.entity';
import { EmailService } from './channels/email.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private notificationsRepository: Repository<Notification>,
    private emailService: EmailService,
    private usersService: UsersService,
  ) {}

  async findAll(): Promise<Notification[]> {
    return this.notificationsRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findByUser(userId: string): Promise<Notification[]> {
    return this.notificationsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findUnreadByUser(userId: string): Promise<Notification[]> {
    return this.notificationsRepository.find({
      where: { userId, isRead: false },
      order: { createdAt: 'DESC' },
    });
  }

  async markAsRead(id: string): Promise<Notification> {
    await this.notificationsRepository.update(id, { isRead: true });
    return this.notificationsRepository.findOne({ where: { id } });
  }

  async markAllAsRead(userId: string): Promise<void> {
    await this.notificationsRepository.update(
      { userId, isRead: false },
      { isRead: true },
    );
  }

  async create(
    userId: string,
    type: NotificationType,
    title: string,
    message: string,
    channel: NotificationChannel,
    relatedId?: string,
    metadata?: any,
  ): Promise<Notification> {
    const notification = this.notificationsRepository.create({
      userId,
      type,
      title,
      message,
      channel,
      relatedId,
      metadata,
    });
    
    return this.notificationsRepository.save(notification);
  }

  async sendEmailNotification(
    userId: string,
    subject: string,
    htmlContent: string,
    textContent?: string,
    relatedId?: string,
    metadata?: any,
  ): Promise<void> {
    // Get user email
    const user = await this.usersService.findById(userId);
    
    // Send email
    await this.emailService.sendEmail(
      user.email,
      subject,
      htmlContent,
      textContent,
    );
    
    // Create notification record
    await this.create(
      userId,
      NotificationType.SYSTEM,
      subject,
      textContent || 'Email notification',
      NotificationChannel.EMAIL,
      relatedId,
      metadata,
    );
  }

  async sendReservationCreatedNotifications(
    reservation: any,
    user: any,
    host: any,
  ): Promise<void> {
    // Notify host
    const hostHtmlContent = `
      <h2>New Reservation Request</h2>
      <p>Hello ${host.firstName},</p>
      <p>${user.firstName} ${user.lastName} has booked a session with you on ${new Date(reservation.startTime).toLocaleString()}.</p>
      <p>Please check your dashboard for more details.</p>
    `;
    
    await this.sendEmailNotification(
      host.id,
      'New Reservation Request',
      hostHtmlContent,
      `New Reservation Request: ${user.firstName} ${user.lastName} has booked a session with you on ${new Date(reservation.startTime).toLocaleString()}.`,
      reservation.id,
      { reservationId: reservation.id },
    );
    
    // Notify user
    const userHtmlContent = `
      <h2>Reservation Confirmation</h2>
      <p>Hello ${user.firstName},</p>
      <p>Your session with ${host.firstName} ${host.lastName} has been scheduled for ${new Date(reservation.startTime).toLocaleString()}.</p>
      <p>Please check your dashboard for more details.</p>
    `;
    
    await this.sendEmailNotification(
      user.id,
      'Reservation Confirmation',
      userHtmlContent,
      `Reservation Confirmation: Your session with ${host.firstName} ${host.lastName} has been scheduled for ${new Date(reservation.startTime).toLocaleString()}.`,
      reservation.id,
      { reservationId: reservation.id },
    );
  }

  async sendReservationReminderNotifications(
    reservation: any,
    user: any,
    host: any,
  ): Promise<void> {
    // Remind host
    const hostHtmlContent = `
      <h2>Upcoming Session Reminder</h2>
      <p>Hello ${host.firstName},</p>
      <p>This is a reminder that you have a session with ${user.firstName} ${user.lastName} on ${new Date(reservation.startTime).toLocaleString()}.</p>
      <p>Please be ready to join the call a few minutes before the scheduled time.</p>
    `;
    
    await this.sendEmailNotification(
      host.id,
      'Upcoming Session Reminder',
      hostHtmlContent,
      `Upcoming Session Reminder: You have a session with ${user.firstName} ${user.lastName} on ${new Date(reservation.startTime).toLocaleString()}.`,
      reservation.id,
      { reservationId: reservation.id },
    );
    
    // Remind user
    const userHtmlContent = `
      <h2>Upcoming Session Reminder</h2>
      <p>Hello ${user.firstName},</p>
      <p>This is a reminder that you have a session with ${host.firstName} ${host.lastName} on ${new Date(reservation.startTime).toLocaleString()}.</p>
      <p>Please be ready to join the call a few minutes before the scheduled time.</p>
    `;
    
    await this.sendEmailNotification(
      user.id,
      'Upcoming Session Reminder',
      userHtmlContent,
      `Upcoming Session Reminder: You have a session with ${host.firstName} ${host.lastName} on ${new Date(reservation.startTime).toLocaleString()}.`,
      reservation.id,
      { reservationId: reservation.id },
    );
  }
}
