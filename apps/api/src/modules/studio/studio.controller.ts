import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth.types';
import { CurrentUser } from '../../common/current-user.decorator';
import { JwtAuthGuard } from '../../common/jwt-auth.guard';
import { PrismaService } from '../../common/prisma.service';

@ApiTags('studio')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('studio')
export class StudioController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async current(@CurrentUser() user: AuthUser) {
    return this.prisma.studio.findUniqueOrThrow({ where: { id: user.studioId } });
  }
}
