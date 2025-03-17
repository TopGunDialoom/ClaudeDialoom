import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Achievement,
  AchievementTrigger,
} from './entities/achievement.entity';
import { UserAchievement } from './entities/user-achievement.entity';
import { UsersService } from '../users/users.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType, NotificationChannel } from '../notifications/entities/notification.entity';

@Injectable()
export class GamificationService {
  constructor(
    @InjectRepository(Achievement)
    private achievementsRepository: Repository<Achievement>,
    @InjectRepository(UserAchievement)
    private userAchievementsRepository: Repository<UserAchievement>,
    private usersService: UsersService,
    private notificationsService: NotificationsService,
  ) {}

  async findAllAchievements(): Promise<Achievement[]> {
    return this.achievementsRepository.find({ where: { isActive: true } });
  }

  async findAchievementById(id: string): Promise<Achievement> {
    const achievement = await this.achievementsRepository.findOne({
      where: { id },
    });
    
    if (!achievement) {
      throw new NotFoundException(`Achievement with ID ${id} not found`);
    }
    
    return achievement;
  }

  async createAchievement(achievementData: Partial<Achievement>): Promise<Achievement> {
    const achievement = this.achievementsRepository.create(achievementData);
    return this.achievementsRepository.save(achievement);
  }

  async updateAchievement(
    id: string,
    achievementData: Partial<Achievement>,
  ): Promise<Achievement> {
    await this.findAchievementById(id); // Check if achievement exists
    
    await this.achievementsRepository.update(id, achievementData);
    return this.findAchievementById(id);
  }

  async deleteAchievement(id: string): Promise<void> {
    await this.findAchievementById(id); // Check if achievement exists
    await this.achievementsRepository.delete(id);
  }

  async getUserAchievements(userId: string): Promise<UserAchievement[]> {
    return this.userAchievementsRepository.find({
      where: { userId },
      relations: ['achievement'],
    });
  }

  async awardAchievement(
    userId: string,
    achievementId: string,
  ): Promise<UserAchievement> {
    // Check if user already has this achievement
    const existingAward = await this.userAchievementsRepository.findOne({
      where: { userId, achievementId },
    });
    
    if (existingAward) {
      return existingAward;
    }
    
    // Get achievement details
    const achievement = await this.findAchievementById(achievementId);
    
    // Create user achievement
    const userAchievement = this.userAchievementsRepository.create({
      userId,
      achievementId,
    });
    
    const savedAward = await this.userAchievementsRepository.save(userAchievement);
    
    // Award points
    if (achievement.points > 0) {
      await this.usersService.updatePoints(userId, achievement.points);
    }
    
    // Send notification
    await this.notificationsService.create(
      userId,
      NotificationType.ACHIEVEMENT_UNLOCKED,
      'Achievement Unlocked!',
      `You've earned the "${achievement.name}" achievement: ${achievement.description}`,
      NotificationChannel.IN_APP,
      achievement.id,
      { achievementId: achievement.id },
    );
    
    return savedAward;
  }

  async checkSessionsAchievements(userId: string, sessionCount: number, isHost: boolean): Promise<void> {
    // Find all achievements related to session count for this user type
    const eligibleAchievements = await this.achievementsRepository.find({
      where: {
        trigger: AchievementTrigger.SESSIONS_COMPLETED,
        role: isHost ? 'host' : 'user',
        threshold: sessionCount, // Exact match for simplicity
        isActive: true,
      },
    });
    
    // Award each eligible achievement
    for (const achievement of eligibleAchievements) {
      await this.awardAchievement(userId, achievement.id);
    }
  }

  async checkRatingAchievements(userId: string, rating: number): Promise<void> {
    // Find all achievements related to rating thresholds
    const eligibleAchievements = await this.achievementsRepository.find({
      where: {
        trigger: AchievementTrigger.RATING_THRESHOLD,
        role: 'host', // Only hosts get rating achievements
        threshold: rating, // Simplified: exact match of average rating
        isActive: true,
      },
    });
    
    // Award each eligible achievement
    for (const achievement of eligibleAchievements) {
      await this.awardAchievement(userId, achievement.id);
    }
  }
}
