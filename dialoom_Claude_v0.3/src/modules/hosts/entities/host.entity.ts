import {
  Entity,
  PrimaryColumn,
  Column,
  OneToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('hosts')
export class Host {
  @PrimaryColumn()
  userId: string;

  @OneToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'text', nullable: true })
  bio: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  hourlyRate: number;

  @Column({ default: false })
  isVerified: boolean;

  @Column({ default: false })
  isFeatured: boolean;

  @Column({ nullable: true })
  stripeConnectId: string;

  @Column({ nullable: true })
  profileImage: string;

  @Column({ nullable: true })
  bannerImage: string;

  @Column('simple-array', { nullable: true })
  specialties: string[];

  @Column('simple-array', { nullable: true })
  languages: string[];

  @Column({ type: 'int', default: 0 })
  totalSessions: number;

  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
  averageRating: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations will be added here as needed
}
