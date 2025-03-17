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
import { UsersService } from './users.service';
import { User, UserRole } from './entities/user.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@ApiTags('users')
@Controller('users')
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get all users' })
  findAll(): Promise<User[]> {
    return this.usersService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new user' })
  create(@Body() userData: Partial<User>): Promise<User> {
    return this.usersService.create(userData);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a user' })
  update(@Param('id') id: string, @Body() userData: Partial<User>): Promise<User> {
    return this.usersService.update(id, userData);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Delete a user' })
  remove(@Param('id') id: string): Promise<void> {
    return this.usersService.delete(id);
  }

  @Put(':id/verify')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Verify a user' })
  verifyUser(@Param('id') id: string): Promise<User> {
    return this.usersService.verifyUser(id);
  }

  @Put(':id/ban')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Ban a user' })
  banUser(@Param('id') id: string): Promise<User> {
    return this.usersService.banUser(id);
  }

  @Put(':id/unban')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Unban a user' })
  unbanUser(@Param('id') id: string): Promise<User> {
    return this.usersService.unbanUser(id);
  }

  @Put(':id/role')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Update user role' })
  updateRole(
    @Param('id') id: string,
    @Body('role') role: UserRole,
  ): Promise<User> {
    return this.usersService.updateRole(id, role);
  }
}
