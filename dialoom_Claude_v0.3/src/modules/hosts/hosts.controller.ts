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
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { HostsService } from './hosts.service';
import { Host } from './entities/host.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('hosts')
@Controller('hosts')
@ApiBearerAuth()
export class HostsController {
  constructor(private readonly hostsService: HostsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all hosts' })
  @ApiQuery({ name: 'featured', required: false, type: Boolean })
  findAll(@Query('featured') featured?: boolean): Promise<Host[]> {
    return this.hostsService.findAll(featured ? featured === true : null);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get host by ID' })
  findOne(@Param('id') id: string): Promise<Host> {
    return this.hostsService.findById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new host profile for user' })
  create(
    @Body('userId') userId: string,
    @Body() hostData: Partial<Host>,
  ): Promise<Host> {
    return this.hostsService.create(userId, hostData);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a host profile' })
  update(
    @Param('id') id: string,
    @Body() hostData: Partial<Host>,
  ): Promise<Host> {
    return this.hostsService.update(id, hostData);
  }

  @Put(':id/verify')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Verify a host' })
  verify(@Param('id') id: string): Promise<Host> {
    return this.hostsService.verify(id);
  }

  @Put(':id/featured')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Set featured status for a host' })
  setFeatured(
    @Param('id') id: string,
    @Body('featured') featured: boolean,
  ): Promise<Host> {
    return this.hostsService.setFeatured(id, featured);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Delete a host profile' })
  remove(@Param('id') id: string): Promise<void> {
    return this.hostsService.delete(id);
  }
}
