import { HttpStatus, Injectable } from '@nestjs/common';
import { BookingStatus } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import type { AuthUser } from '../../common/auth.types';
import { AppError } from '../../common/errors';
import { PrismaService } from '../../common/prisma.service';
import type { BookDto, CancelDto } from './dto/booking.dto';
import { purgeEndedSessionLogs, SESSION_LOG, writeSessionLog } from './session-log';

const HOLDING: BookingStatus[] = [BookingStatus.booked, BookingStatus.attended];

function canCancelOthers(actor: AuthUser) {
  return actor.permissions.includes('book_others') || actor.permissions.includes('manage_schedule');
}

@Injectable()
export class BookingService {
  constructor(private readonly prisma: PrismaService) {}

  async book(actor: AuthUser, sessionId: string, dto: BookDto) {
    const targetUserId = dto.userId ?? actor.userId;
    if (targetUserId !== actor.userId && !actor.permissions.includes('book_others')) {
      throw new AppError(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Cannot book for another user');
    }
    if (targetUserId === actor.userId && !actor.permissions.includes('book_self')) {
      throw new AppError(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Cannot book yourself');
    }

    return this.prisma.$transaction(async (tx) => {
      await tx.$queryRaw`SELECT id FROM sessions WHERE id = ${sessionId}::uuid FOR UPDATE`;
      const session = await tx.session.findFirst({
        where: { id: sessionId, studioId: actor.studioId },
      });
      if (!session) {
        throw new AppError(HttpStatus.NOT_FOUND, 'SESSION_NOT_FOUND', 'Session not found');
      }
      if (session.startsAt <= new Date()) {
        throw new AppError(HttpStatus.BAD_REQUEST, 'SESSION_STARTED', 'Session already started');
      }

      const existing = await tx.booking.findUnique({
        where: { sessionId_userId: { sessionId, userId: targetUserId } },
      });
      if (existing && HOLDING.includes(existing.status)) {
        throw new AppError(HttpStatus.CONFLICT, 'ALREADY_BOOKED', 'Already booked');
      }

      const count = await tx.booking.count({
        where: { sessionId, status: { in: HOLDING } },
      });
      if (count >= session.capacity) {
        throw new AppError(HttpStatus.CONFLICT, 'BOOKING_FULL', 'Session is full');
      }

      const row = existing
        ? await tx.booking.update({
            where: { id: existing.id },
            data: { status: BookingStatus.booked },
          })
        : await tx.booking.create({
            data: {
              id: uuidv7(),
              studioId: actor.studioId,
              sessionId,
              userId: targetUserId,
              status: BookingStatus.booked,
            },
          });
      await writeSessionLog(tx, {
        studioId: actor.studioId,
        sessionId,
        actorId: actor.userId,
        targetId: targetUserId,
        action: SESSION_LOG.booked,
      });
      return row;
    });
  }

  async cancel(actor: AuthUser, bookingId: string, dto: CancelDto = {}) {
    return this.prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findFirst({
        where: { id: bookingId, studioId: actor.studioId },
        include: { session: { include: { studio: true } } },
      });
      if (!booking) {
        throw new AppError(HttpStatus.NOT_FOUND, 'BOOKING_NOT_FOUND', 'Booking not found');
      }
      if (booking.userId !== actor.userId && !canCancelOthers(actor)) {
        throw new AppError(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Cannot cancel this booking');
      }
      if (booking.status !== BookingStatus.booked) {
        throw new AppError(HttpStatus.BAD_REQUEST, 'NOT_CANCELLABLE', 'Booking cannot be cancelled');
      }
      const hours = (booking.session.startsAt.getTime() - Date.now()) / 3600000;
      const canOverride = actor.permissions.includes('manage_schedule');
      if (!canOverride && hours < booking.session.studio.cancellationHoursBefore) {
        throw new AppError(HttpStatus.BAD_REQUEST, 'CANCEL_TOO_LATE', 'Too late to cancel');
      }
      const row = await tx.booking.update({
        where: { id: booking.id },
        data: { status: BookingStatus.cancelled },
      });
      await writeSessionLog(tx, {
        studioId: actor.studioId,
        sessionId: booking.sessionId,
        actorId: actor.userId,
        targetId: booking.userId,
        action: booking.userId === actor.userId ? SESSION_LOG.cancelled : SESSION_LOG.cancelledOther,
        comment: dto.comment,
      });
      return row;
    });
  }

  async checkIn(actor: AuthUser, bookingId: string) {
    return this.prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findFirst({
        where: { id: bookingId, studioId: actor.studioId },
      });
      if (!booking || booking.status !== BookingStatus.booked) {
        throw new AppError(HttpStatus.BAD_REQUEST, 'CHECKIN_INVALID', 'Cannot check in');
      }
      const pass = await tx.pass.findFirst({
        where: {
          userId: booking.userId,
          studioId: actor.studioId,
          remainingVisits: { gt: 0 },
          OR: [{ validUntil: null }, { validUntil: { gte: new Date() } }],
        },
        orderBy: { validUntil: 'asc' },
      });
      if (!pass) {
        throw new AppError(HttpStatus.BAD_REQUEST, 'NO_PASS', 'No remaining visits');
      }
      await tx.pass.update({
        where: { id: pass.id },
        data: { remainingVisits: { decrement: 1 } },
      });
      await tx.ledgerEntry.create({
        data: {
          id: uuidv7(),
          studioId: actor.studioId,
          userId: booking.userId,
          bookingId: booking.id,
          createdById: actor.userId,
          type: 'debit',
          visits: -1,
          note: 'Check-in',
        },
      });
      const row = await tx.booking.update({
        where: { id: booking.id },
        data: { status: BookingStatus.attended },
      });
      await writeSessionLog(tx, {
        studioId: actor.studioId,
        sessionId: booking.sessionId,
        actorId: actor.userId,
        targetId: booking.userId,
        action: SESSION_LOG.checkedIn,
      });
      return row;
    });
  }

  async listLog(actor: AuthUser, sessionId: string) {
    await purgeEndedSessionLogs(this.prisma, actor.studioId);
    const session = await this.prisma.session.findFirst({
      where: { id: sessionId, studioId: actor.studioId },
    });
    if (!session) {
      throw new AppError(HttpStatus.NOT_FOUND, 'SESSION_NOT_FOUND', 'Session not found');
    }
    if (session.endsAt <= new Date()) {
      return [];
    }
    const rows = await this.prisma.sessionLog.findMany({
      where: { studioId: actor.studioId, sessionId },
      include: {
        actor: { select: { id: true, name: true } },
        target: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
    return rows.map((row) => ({
      id: row.id,
      action: row.action,
      comment: row.comment,
      createdAt: row.createdAt,
      actor: row.actor,
      target: row.target,
    }));
  }

  myBookings(actor: AuthUser) {
    return this.prisma.booking.findMany({
      where: { studioId: actor.studioId, userId: actor.userId },
      include: { session: { include: { classType: true } } },
      orderBy: { session: { startsAt: 'desc' } },
    });
  }
}
