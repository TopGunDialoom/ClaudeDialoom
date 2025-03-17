import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Host } from './entities/host.entity';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/entities/user.entity';

@Injectable()
export class HostsService {
  constructor(
    @InjectRepository(Host)
    private hostsRepository: Repository<Host>,
    private usersService: UsersService,
  ) {}

  async findAll(featured: boolean = null): Promise<Host[]> {
    const query = this.hostsRepository.createQueryBuilder('host')
      .leftJoinAndSelect('host.user', 'user')
      .where('user.isBanned = :isBanned', { isBanned: false });
    
    if (featured !== null) {
      query.andWhere('host.isFeatured = :featured', { featured });
    }
    
    return query.getMany();
  }

  async findById(id: string): Promise<Host> {
    const host = await this.hostsRepository.findOne({
      where: { userId: id },
      relations: ['user'],
    });
    
    if (!host) {
      throw new NotFoundException(`Host with ID ${id} not found`);
    }
    
    return host;
  }

  async create(userId: string, hostData: Partial<Host>): Promise<Host> {
    // Check if user exists and is not already a host
    const user = await this.usersService.findById(userId);
    
    const existingHost = await this.hostsRepository.findOne({
      where: { userId },
    });
    
    if (existingHost) {
      throw new ConflictException(`User ${userId} is already a host`);
    }
    
    // Update user role to HOST
    await this.usersService.updateRole(userId, UserRole.HOST);
    
    // Create new host profile
    const newHost = this.hostsRepository.create({
      userId,
      ...hostData,
    });
    
    return this.hostsRepository.save(newHost);
  }

  async update(id: string, hostData: Partial<Host>): Promise<Host> {
    await this.findById(id); // Check if host exists
    
    await this.hostsRepository.update({ userId: id }, hostData);
    return this.findById(id);
  }

  async verify(id: string): Promise<Host> {
    const host = await this.findById(id);
    host.isVerified = true;
    return this.hostsRepository.save(host);
  }

  async setFeatured(id: string, featured: boolean): Promise<Host> {
    const host = await this.findById(id);
    host.isFeatured = featured;
    return this.hostsRepository.save(host);
  }

  async updateRating(id: string, rating: number): Promise<Host> {
    const host = await this.findById(id);
    
    // Calculate new average rating
    const totalSessions = host.totalSessions + 1;
    const currentTotalRating = host.averageRating * host.totalSessions;
    const newAverageRating = (currentTotalRating + rating) / totalSessions;
    
    // Update host
    host.totalSessions = totalSessions;
    host.averageRating = Number(newAverageRating.toFixed(2));
    
    return this.hostsRepository.save(host);
  }

  async delete(id: string): Promise<void> {
    const host = await this.findById(id);
    
    // Change user role back to USER
    await this.usersService.updateRole(host.userId, UserRole.USER);
    
    // Delete host profile
    await this.hostsRepository.remove(host);
  }
}
