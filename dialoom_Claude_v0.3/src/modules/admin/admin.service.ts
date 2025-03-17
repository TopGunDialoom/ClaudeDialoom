import { Repository, MoreThanOrEqual, LessThanOrEqual } from "typeorm";
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ThemeSettings } from './entities/theme-settings.entity';
import { Content, ContentType } from './entities/content.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(ThemeSettings)
    private themeSettingsRepository: Repository<ThemeSettings>,
    @InjectRepository(Content)
    private contentRepository: Repository<Content>,
  ) {}

  // Theme Settings
  async getThemeSettings(): Promise<ThemeSettings> {
    const settings = await this.themeSettingsRepository.find({
      take: 1,
      order: { createdAt: 'DESC' },
    });
    
    if (settings.length === 0) {
      // Create default theme settings if none exist
      return this.themeSettingsRepository.save(
        this.themeSettingsRepository.create(),
      );
    }
    
    return settings[0];
  }

  async updateThemeSettings(
    themeData: Partial<ThemeSettings>,
  ): Promise<ThemeSettings> {
    const settings = await this.getThemeSettings();
    
    // Update fields
    Object.assign(settings, themeData);
    
    return this.themeSettingsRepository.save(settings);
  }

  // Content Management
  async getAllContent(): Promise<Content[]> {
    return this.contentRepository.find({
      order: { 
        isPinned: 'DESC',
        displayOrder: 'ASC',
        createdAt: 'DESC',
      },
    });
  }

  async getActiveContent(): Promise<Content[]> {
    const now = new Date();
    
    return this.contentRepository.find({
      where: [
        {
          isActive: true,
          startDate: null,
          endDate: null,
        },
        {
          isActive: true,
          startDate: null,
          endDate: MoreThanOrEqual(now),
        },
        {
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: null,
        },
        {
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: MoreThanOrEqual(now),
        },
      ],
      order: {
        isPinned: 'DESC',
        displayOrder: 'ASC',
        createdAt: 'DESC',
      },
    });
  }

  async getContentByType(type: ContentType): Promise<Content[]> {
    const now = new Date();
    
    return this.contentRepository.find({
      where: [
        {
          type,
          isActive: true,
          startDate: null,
          endDate: null,
        },
        {
          type,
          isActive: true,
          startDate: null,
          endDate: MoreThanOrEqual(now),
        },
        {
          type,
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: null,
        },
        {
          type,
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: MoreThanOrEqual(now),
        },
      ],
      order: {
        isPinned: 'DESC',
        displayOrder: 'ASC',
        createdAt: 'DESC',
      },
    });
  }

  async getContentById(id: string): Promise<Content> {
    const content = await this.contentRepository.findOne({
      where: { id },
    });
    
    if (!content) {
      throw new NotFoundException(`Content with ID ${id} not found`);
    }
    
    return content;
  }

  async createContent(contentData: Partial<Content>): Promise<Content> {
    const content = this.contentRepository.create(contentData);
    return this.contentRepository.save(content);
  }

  async updateContent(
    id: string,
    contentData: Partial<Content>,
  ): Promise<Content> {
    await this.getContentById(id); // Check if content exists
    
    await this.contentRepository.update(id, contentData);
    return this.getContentById(id);
  }

  async deleteContent(id: string): Promise<void> {
    await this.getContentById(id); // Check if content exists
    await this.contentRepository.delete(id);
  }
}
