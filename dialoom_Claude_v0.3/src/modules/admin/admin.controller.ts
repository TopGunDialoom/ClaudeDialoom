import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { ThemeSettings } from './entities/theme-settings.entity';
import { Content, ContentType } from './entities/content.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('admin')
@Controller('admin')
@Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
@UseGuards(RolesGuard)
@ApiBearerAuth()
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  // Theme Settings
  @Get('theme')
  @ApiOperation({ summary: 'Get theme settings' })
  getThemeSettings(): Promise<ThemeSettings> {
    return this.adminService.getThemeSettings();
  }

  @Put('theme')
  @ApiOperation({ summary: 'Update theme settings' })
  updateThemeSettings(
    @Body() themeData: Partial<ThemeSettings>,
  ): Promise<ThemeSettings> {
    return this.adminService.updateThemeSettings(themeData);
  }

  // Content Management
  @Get('content')
  @ApiOperation({ summary: 'Get all content' })
  getAllContent(): Promise<Content[]> {
    return this.adminService.getAllContent();
  }

  @Get('content/active')
  @ApiOperation({ summary: 'Get active content' })
  getActiveContent(): Promise<Content[]> {
    return this.adminService.getActiveContent();
  }

  @Get('content/type/:type')
  @ApiOperation({ summary: 'Get content by type' })
  getContentByType(@Param('type') type: ContentType): Promise<Content[]> {
    return this.adminService.getContentByType(type);
  }

  @Get('content/:id')
  @ApiOperation({ summary: 'Get content by ID' })
  getContentById(@Param('id') id: string): Promise<Content> {
    return this.adminService.getContentById(id);
  }

  @Post('content')
  @ApiOperation({ summary: 'Create new content' })
  createContent(@Body() contentData: Partial<Content>): Promise<Content> {
    return this.adminService.createContent(contentData);
  }

  @Put('content/:id')
  @ApiOperation({ summary: 'Update content' })
  updateContent(
    @Param('id') id: string,
    @Body() contentData: Partial<Content>,
  ): Promise<Content> {
    return this.adminService.updateContent(id, contentData);
  }

  @Delete('content/:id')
  @ApiOperation({ summary: 'Delete content' })
  deleteContent(@Param('id') id: string): Promise<void> {
    return this.adminService.deleteContent(id);
  }
}
