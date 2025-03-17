import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum AchievementTrigger {
  SESSIONS_COMPLETED = 'sessions_completed',
  RATING_THRESHOLD = 'rating_threshold',
  ACCOUNT_AGE = 'account_age',
  CUSTOM = 'custom',
}

@Entity('achievements')
export class Achievement {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ nullable: true })
  icon: string;

  @Column({ nullable: true })
  emoji: string;

  @Column({ type: 'enum', enum: AchievementTrigger })
  trigger: AchievementTrigger;

  @Column({ type: 'int' })
  threshold: number;

  @Column({ default: 0 })
  points: number;

  @Column()
  role: string; // 'user' or 'host'

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
