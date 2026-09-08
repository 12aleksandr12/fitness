import { HttpStatus, Injectable } from '@nestjs/common';
import { v7 as uuidv7 } from 'uuid';
import type { AuthUser } from '../../common/auth.types';
import { AppError } from '../../common/errors';
import { PrismaService } from '../../common/prisma.service';
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
    const sessions = await this.prisma.session.findMany({
      where: { studioId, startsAt: { gte: from, lt: to } },
      include: {
        classType: true,
        trainer: { select: { id: true, name: true } },
        bookings: {
          where: { status: { in: [...ACTIVE] } },
          include: { user: { select: { id: true, name: true, email: true } } },
        },
      },
      orderBy: { startsAt: 'asc' },
    });
    return sessions.map((s) => ({
      ...s,
      bookedCount: s.bookings.length,
    }));
  }

  async createSession(actor: AuthUser, dto: CreateSessionDto) {
    const classType = await this.prisma.classType.findFirst({
      where: { id: dto.classTypeId, studioId: actor.studioId },
    });
    if (!classType) {
      throw new AppError(HttpStatus.NOT_FOUND, 'CLASS_TYPE_NOT_FOUND', 'Class type not found');
    }
    return this.prisma.session.create({
      data: {
        id: uuidv7(),
        studioId: actor.studioId,
        classTypeId: dto.classTypeId,
        trainerId: dto.trainerId ?? null,
        room: dto.room,
        startsAt: new Date(dto.startsAt),
        endsAt: new Date(dto.endsAt),
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
    await this.prisma.session.delete({ where: { id } });
    return { ok: true };
  }
}
