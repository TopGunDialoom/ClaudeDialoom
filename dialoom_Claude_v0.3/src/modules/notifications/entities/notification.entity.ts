import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum NotificationType {
  RESERVATION_CREATED = 'reservation_created',
  RESERVATION_UPDATED = 'reservation_updated',
  RESERVATION_CANCELLED = 'reservation_cancelled',
  RESERVATION_REMINDER = 'reservation_reminder',
  PAYMENT_COMPLETED = 'payment_completed',
  PAYMENT_RELEASED = 'payment_released',
  REVIEW_RECEIVED = 'review_received',
  ACHIEVEMENT_UNLOCKED = 'achievement_unlocked',
  SYSTEM = 'system',
}

export enum NotificationChannel {
  IN_APP = 'in_app',
  EMAIL = 'email',
  SMS = 'sms',
  PUSH = 'push',
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'enum', enum: NotificationType })
  type: NotificationType;

  @Column()
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'enum', enum: NotificationChannel })
  channel: NotificationChannel;

  @Column({ default: false })
  isRead: boolean;

  @Column({ nullable: true })
  relatedId: string;

  @Column({ type: 'json', nullable: true })
  metadata: any;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
