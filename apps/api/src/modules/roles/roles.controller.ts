import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth.types';
import { CurrentUser } from '../../common/current-user.decorator';
import { JwtAuthGuard } from '../../common/jwt-auth.guard';
import { PermissionsGuard } from '../../common/permissions.guard';
import { RequirePermission } from '../../common/require-permission.decorator';
import { AssignRoleDto, CreateRoleDto, UpdateRoleDto } from './dto/role.dto';
import { RolesService } from './roles.service';

@ApiTags('roles')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller()
export class RolesController {
  constructor(private readonly roles: RolesService) {}

  @Get('permissions')
  @RequirePermission('manage_roles')
  permissions() {
    return this.roles.listPermissions();
  }

  @Get('roles')
  @RequirePermission('manage_roles')
  list(@CurrentUser() user: AuthUser) {
    return this.roles.listRoles(user.studioId);
  }

  @Post('roles')
  @RequirePermission('manage_roles')
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateRoleDto) {
    return this.roles.create(user, dto);
  }

  @Patch('roles/:id')
  @RequirePermission('manage_roles')
  update(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: UpdateRoleDto) {
    return this.roles.update(user, id, dto);
  }

  @Delete('roles/:id')
  @RequirePermission('manage_roles')
  remove(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.roles.remove(user, id);
  }

  @Post('users/:userId/role')
  @RequirePermission('manage_roles')
  assign(
    @CurrentUser() user: AuthUser,
    @Param('userId') userId: string,
    @Body() dto: AssignRoleDto,
  ) {
    return this.roles.assign(user, userId, dto);
  }
}
