import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth.types';
import { CurrentUser } from '../../common/current-user.decorator';
import { JwtAuthGuard } from '../../common/jwt-auth.guard';
import { PermissionsGuard } from '../../common/permissions.guard';
import { RequirePermission } from '../../common/require-permission.decorator';
import { BookingService } from './booking.service';
import { BookDto } from './dto/booking.dto';

@ApiTags('bookings')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller()
export class BookingController {
  constructor(private readonly bookings: BookingService) {}

  @Get('me/bookings')
  mine(@CurrentUser() user: AuthUser) {
    return this.bookings.myBookings(user);
  }

  @Get('sessions/:id/log')
  listLog(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.bookings.listLog(user, id);
  }

  @Post('sessions/:id/book')
  book(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: BookDto) {
    return this.bookings.book(user, id, dto);
  }

  @Post('bookings/:id/cancel')
  cancel(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.bookings.cancel(user, id);
  }

  @Post('bookings/:id/check-in')
  @RequirePermission('check_in')
  checkIn(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.bookings.checkIn(user, id);
  }
}
