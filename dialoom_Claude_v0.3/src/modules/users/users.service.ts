import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  async findById(id: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async findByEmail(email: string): Promise<User> {
    return this.usersRepository.findOne({ where: { email } });
  }

  async create(userData: Partial<User>): Promise<User> {
    const existingUser = await this.findByEmail(userData.email);
    if (existingUser) {
      throw new ConflictException(`User with email ${userData.email} already exists`);
    }

    if (userData.password) {
      userData.password = await this.hashPassword(userData.password);
    }

    const newUser = this.usersRepository.create(userData);
    return this.usersRepository.save(newUser);
  }

  async update(id: string, userData: Partial<User>): Promise<User> {
    await this.findById(id); // Check if user exists

    if (userData.password) {
      userData.password = await this.hashPassword(userData.password);
    }

    await this.usersRepository.update(id, userData);
    return this.findById(id);
  }

  async delete(id: string): Promise<void> {
    const user = await this.findById(id);
    await this.usersRepository.remove(user);
  }

  async updateRole(id: string, role: UserRole): Promise<User> {
    const user = await this.findById(id);
    user.role = role;
    return this.usersRepository.save(user);
  }

  async verifyUser(id: string): Promise<User> {
    const user = await this.findById(id);
    user.isVerified = true;
    return this.usersRepository.save(user);
  }

  async banUser(id: string): Promise<User> {
    const user = await this.findById(id);
    user.isBanned = true;
    return this.usersRepository.save(user);
  }

  async unbanUser(id: string): Promise<User> {
    const user = await this.findById(id);
    user.isBanned = false;
    return this.usersRepository.save(user);
  }

  async updatePoints(id: string, points: number): Promise<User> {
    const user = await this.findById(id);
    user.points += points;
    return this.usersRepository.save(user);
  }

  private async hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return bcrypt.hash(password, saltRounds);
  }
}
