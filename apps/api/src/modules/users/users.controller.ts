import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth.types';
import { CurrentUser } from '../../common/current-user.decorator';
import { JwtAuthGuard } from '../../common/jwt-auth.guard';
import { PermissionsGuard } from '../../common/permissions.guard';
import { RequirePermission } from '../../common/require-permission.decorator';
import { PrismaService } from '../../common/prisma.service';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @RequirePermission('view_clients')
  list(@CurrentUser() user: AuthUser) {
    return this.prisma.membership.findMany({
      where: { studioId: user.studioId },
      include: {
        user: { select: { id: true, email: true, name: true } },
        role: { select: { id: true, name: true } },
      },
      orderBy: { user: { name: 'asc' } },
    });
  }

  @Get(':id')
  @RequirePermission('view_clients')
  async one(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    const membership = await this.prisma.membership.findFirst({
      where: { studioId: user.studioId, userId: id },
      include: {
        user: { select: { id: true, email: true, name: true } },
        role: { select: { id: true, name: true } },
      },
    });
    return membership;
  }
}
