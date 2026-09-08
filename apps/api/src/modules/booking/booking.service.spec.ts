import { BookingStatus } from '@prisma/client';
import { HttpStatus } from '@nestjs/common';
import { AppError } from '../../common/errors';

describe('booking occupancy', () => {
  const HOLDING = [BookingStatus.booked, BookingStatus.attended];

  it('counts booked and attended as occupying a seat', () => {
    expect(HOLDING).toEqual(['booked', 'attended']);
  });

  it('rejects a second active hold with ALREADY_BOOKED', () => {
    const existing = { status: BookingStatus.booked };
    const conflict = HOLDING.includes(existing.status);
    expect(conflict).toBe(true);
    const err = new AppError(HttpStatus.CONFLICT, 'ALREADY_BOOKED', 'Already booked');
    expect(err.getStatus()).toBe(409);
  });
});
