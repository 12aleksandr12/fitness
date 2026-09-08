import { HttpStatus, Injectable } from '@nestjs/common';
import { v7 as uuidv7 } from 'uuid';
import type { AuthUser } from '../../common/auth.types';
import { AppError } from '../../common/errors';
import { PrismaService } from '../../common/prisma.service';
import { purgeEndedSessionLogs } from '../booking/session-log';
import type { CreateClassTypeDto, CreateSessionDto } from './dto/schedule.dto';

const ACTIVE = ['booked', 'attended'] as const;

@Injectable()
export class ScheduleService {
  constructor(private readonly prisma: PrismaService) {}

  listClassTypes(studioId: string) {
    return this.prisma.classType.findMany({ where: { studioId }, orderBy: { name: 'asc' } });
  }

  createClassType(actor: AuthUser, dto: CreateClassTypeDto) {
    return this.prisma.classType.create({
      data: { id: uuidv7(), studioId: actor.studioId, name: dto.name },
    });
  }

  async listSessions(studioId: string, from: Date, to: Date) {
    await purgeEndedSessionLogs(this.prisma, studioId);
    const sessions = await this.prisma.session.findMany({
      where: { studioId, startsAt: { gte: from, lt: to } },
      include: {
        classType: true,
        trainer: { select: { id: true, name: true, photoExt: true } },
        bookings: {
          where: { status: { in: [...ACTIVE] } },
          include: { user: { select: { id: true, name: true, photoExt: true } } },
        },
      },
      orderBy: { startsAt: 'asc' },
    });
    return sessions.map((s) => ({
      ...s,
      bookedCount: s.bookings.length,
      trainer: s.trainer
        ? { id: s.trainer.id, name: s.trainer.name, hasPhoto: Boolean(s.trainer.photoExt) }
        : null,
      bookings: s.bookings.map((b) => ({
        ...b,
        user: { id: b.user.id, name: b.user.name, hasPhoto: Boolean(b.user.photoExt) },
      })),
    }));
  }

  async createSession(actor: AuthUser, dto: CreateSessionDto) {
    const { startsAt, endsAt } = parseSessionRange(dto.startsAt, dto.endsAt);
    await this.assertClassType(actor.studioId, dto.classTypeId);
    return this.prisma.session.create({
      data: {
        id: uuidv7(),
        studioId: actor.studioId,
        classTypeId: dto.classTypeId,
        trainerId: dto.trainerId ?? null,
        room: dto.room,
        startsAt,
        endsAt,
        capacity: dto.capacity,
      },
    });
  }

  async updateSession(actor: AuthUser, id: string, dto: CreateSessionDto) {
    const session = await this.prisma.session.findFirst({
      where: { id, studioId: actor.studioId },
    });
    if (!session) {
      throw new AppError(HttpStatus.NOT_FOUND, 'SESSION_NOT_FOUND', 'Session not found');
    }
    const { startsAt, endsAt } = parseSessionRange(dto.startsAt, dto.endsAt);
    await this.assertClassType(actor.studioId, dto.classTypeId);
    const booked = await this.prisma.booking.count({
      where: { sessionId: id, status: { in: [...ACTIVE] } },
    });
    if (dto.capacity < booked) {
      throw new AppError(
        HttpStatus.BAD_REQUEST,
        'CAPACITY_BELOW_BOOKED',
        'Capacity cannot be below current bookings',
      );
    }
    return this.prisma.session.update({
      where: { id },
      data: {
        classTypeId: dto.classTypeId,
        trainerId: dto.trainerId ?? null,
        room: dto.room,
        startsAt,
        endsAt,
        capacity: dto.capacity,
      },
    });
  }

  async removeSession(actor: AuthUser, id: string) {
    const session = await this.prisma.session.findFirst({
      where: { id, studioId: actor.studioId },
    });
    if (!session) {
      throw new AppError(HttpStatus.NOT_FOUND, 'SESSION_NOT_FOUND', 'Session not found');
    }
    const active = await this.prisma.booking.count({
      where: { sessionId: id, status: { in: [...ACTIVE] } },
    });
    if (active > 0) {
      throw new AppError(
        HttpStatus.CONFLICT,
        'SESSION_HAS_BOOKINGS',
        'Cannot delete a session with bookings',
      );
    }
    await this.prisma.$transaction([
      this.prisma.booking.deleteMany({ where: { sessionId: id } }),
      this.prisma.session.delete({ where: { id } }),
    ]);
    return { ok: true };
  }

  private async assertClassType(studioId: string, classTypeId: string) {
    const classType = await this.prisma.classType.findFirst({
      where: { id: classTypeId, studioId },
    });
    if (!classType) {
      throw new AppError(HttpStatus.NOT_FOUND, 'CLASS_TYPE_NOT_FOUND', 'Class type not found');
    }
  }
}

function parseSessionRange(startsAtRaw: string, endsAtRaw: string) {
  const startsAt = new Date(startsAtRaw);
  const endsAt = new Date(endsAtRaw);
  if (Number.isNaN(startsAt.getTime()) || Number.isNaN(endsAt.getTime()) || endsAt <= startsAt) {
    throw new AppError(HttpStatus.BAD_REQUEST, 'INVALID_SESSION_RANGE', 'Session end must be after start');
  }
  return { startsAt, endsAt };
}
