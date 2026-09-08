import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth.types';
import { CurrentUser } from '../../common/current-user.decorator';
import { JwtAuthGuard } from '../../common/jwt-auth.guard';
import { PermissionsGuard } from '../../common/permissions.guard';
import { RequirePermission } from '../../common/require-permission.decorator';
import { AdjustBalanceDto, CreatePassDto } from './dto/ledger.dto';
import { LedgerService } from './ledger.service';

@ApiTags('ledger')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller()
export class LedgerController {
  constructor(private readonly ledger: LedgerService) {}

  @Get('me/passes')
  myPasses(@CurrentUser() user: AuthUser) {
    return this.ledger.passes(user, user.userId);
  }

  @Get('me/ledger')
  myLedger(@CurrentUser() user: AuthUser) {
    return this.ledger.list(user, user.userId);
  }

  @Get('users/:id/ledger')
  list(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.ledger.list(user, id);
  }

  @Get('users/:id/passes')
  passes(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.ledger.passes(user, id);
  }

  @Post('users/:id/passes')
  @RequirePermission('adjust_balance')
  createPass(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: CreatePassDto,
  ) {
    return this.ledger.createPass(user, id, dto);
  }

  @Post('users/:id/ledger')
  @RequirePermission('adjust_balance')
  adjust(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: AdjustBalanceDto) {
    return this.ledger.adjust(user, id, dto);
  }
}
