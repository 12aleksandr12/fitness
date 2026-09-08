import { HttpStatus, Injectable } from '@nestjs/common';
import { v7 as uuidv7 } from 'uuid';
import type { AuthUser } from '../../common/auth.types';
import { AppError } from '../../common/errors';
import { PrismaService } from '../../common/prisma.service';
import type { AdjustBalanceDto, CreatePassDto } from './dto/ledger.dto';

@Injectable()
export class LedgerService {
  constructor(private readonly prisma: PrismaService) {}

  async list(actor: AuthUser, userId: string) {
    await this.assertCanView(actor, userId);
    return this.prisma.ledgerEntry.findMany({
      where: { studioId: actor.studioId, userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async passes(actor: AuthUser, userId: string) {
    await this.assertCanView(actor, userId);
    return this.prisma.pass.findMany({
      where: { studioId: actor.studioId, userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createPass(actor: AuthUser, userId: string, dto: CreatePassDto) {
    return this.prisma.$transaction(async (tx) => {
      const pass = await tx.pass.create({
        data: {
          id: uuidv7(),
          studioId: actor.studioId,
          userId,
          name: dto.name,
          remainingVisits: dto.visits,
          validFrom: new Date(),
        },
      });
      await tx.ledgerEntry.create({
        data: {
          id: uuidv7(),
          studioId: actor.studioId,
          userId,
          createdById: actor.userId,
          type: 'credit',
          visits: dto.visits,
          note: dto.name,
        },
      });
      return pass;
    });
  }

  async adjust(actor: AuthUser, userId: string, dto: AdjustBalanceDto) {
    const membership = await this.prisma.membership.findFirst({
      where: { studioId: actor.studioId, userId },
    });
    if (!membership) {
      throw new AppError(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'User not in studio');
    }
    return this.prisma.$transaction(async (tx) => {
      const pass = await tx.pass.findFirst({
        where: { studioId: actor.studioId, userId },
        orderBy: { createdAt: 'desc' },
      });
      if (pass) {
        await tx.pass.update({
          where: { id: pass.id },
          data: { remainingVisits: { increment: dto.visits } },
        });
      } else if (dto.visits > 0) {
        await tx.pass.create({
          data: {
            id: uuidv7(),
            studioId: actor.studioId,
            userId,
            name: 'Корректировка',
            remainingVisits: dto.visits,
          },
        });
      } else {
        throw new AppError(HttpStatus.BAD_REQUEST, 'NO_PASS', 'No pass to debit');
      }
      return tx.ledgerEntry.create({
        data: {
          id: uuidv7(),
          studioId: actor.studioId,
          userId,
          createdById: actor.userId,
          type: 'adjust',
          visits: dto.visits,
          note: dto.note ?? 'Manual adjust',
        },
      });
    });
  }

  private async assertCanView(actor: AuthUser, userId: string) {
    if (userId === actor.userId) {
      return;
    }
    if (!actor.permissions.includes('view_clients') && !actor.permissions.includes('adjust_balance')) {
      throw new AppError(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Cannot view this ledger');
    }
  }
}
