import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { GamificationService } from './gamification.service';
import { Achievement } from './entities/achievement.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('gamification')
@Controller('gamification')
@ApiBearerAuth()
export class GamificationController {
  constructor(private readonly gamificationService: GamificationService) {}

  @Get('achievements')
  @ApiOperation({ summary: 'Get all achievements' })
  findAllAchievements(): Promise<Achievement[]> {
    return this.gamificationService.findAllAchievements();
  }

  @Get('achievements/:id')
  @ApiOperation({ summary: 'Get achievement by ID' })
  findAchievementById(@Param('id') id: string): Promise<Achievement> {
    return this.gamificationService.findAchievementById(id);
  }

  @Post('achievements')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Create a new achievement (admin only)' })
  createAchievement(@Body() achievementData: Partial<Achievement>): Promise<Achievement> {
    return this.gamificationService.createAchievement(achievementData);
  }

  @Put('achievements/:id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Update an achievement (admin only)' })
  updateAchievement(
    @Param('id') id: string,
    @Body() achievementData: Partial<Achievement>,
  ): Promise<Achievement> {
    return this.gamificationService.updateAchievement(id, achievementData);
  }

  @Delete('achievements/:id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Delete an achievement (admin only)' })
  deleteAchievement(@Param('id') id: string): Promise<void> {
    return this.gamificationService.deleteAchievement(id);
  }

  @Get('my-achievements')
  @ApiOperation({ summary: 'Get current user achievements' })
  getUserAchievements(@Req() req) {
    return this.gamificationService.getUserAchievements(req.user.id);
  }

  @Post('award')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Award an achievement to a user (admin only)' })
  awardAchievement(
    @Body() data: { userId: string; achievementId: string },
  ) {
    return this.gamificationService.awardAchievement(
      data.userId,
      data.achievementId,
    );
  }
}
