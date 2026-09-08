import { Body, Controller, Delete, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth.types';
import { CurrentUser } from '../../common/current-user.decorator';
import { JwtAuthGuard } from '../../common/jwt-auth.guard';
import { PermissionsGuard } from '../../common/permissions.guard';
import { RequirePermission } from '../../common/require-permission.decorator';
import { CreateClassTypeDto, CreateSessionDto } from './dto/schedule.dto';
import { ScheduleService } from './schedule.service';

@ApiTags('schedule')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller()
export class ScheduleController {
  constructor(private readonly schedule: ScheduleService) {}

  @Get('class-types')
  listTypes(@CurrentUser() user: AuthUser) {
    return this.schedule.listClassTypes(user.studioId);
  }

  @Post('class-types')
  @RequirePermission('manage_schedule')
  createType(@CurrentUser() user: AuthUser, @Body() dto: CreateClassTypeDto) {
    return this.schedule.createClassType(user, dto);
  }

  @Get('sessions')
  listSessions(
    @CurrentUser() user: AuthUser,
    @Query('from') from: string,
    @Query('to') to: string,
  ) {
    const fromDate = from ? new Date(from) : new Date();
    const toDate = to ? new Date(to) : new Date(fromDate.getTime() + 7 * 24 * 3600 * 1000);
    return this.schedule.listSessions(user.studioId, fromDate, toDate);
  }

  @Post('sessions')
  @RequirePermission('manage_schedule')
  createSession(@CurrentUser() user: AuthUser, @Body() dto: CreateSessionDto) {
    return this.schedule.createSession(user, dto);
  }

  @Delete('sessions/:id')
  @RequirePermission('manage_schedule')
  removeSession(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.schedule.removeSession(user, id);
  }
}
