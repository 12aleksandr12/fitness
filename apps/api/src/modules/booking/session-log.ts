import { v7 as uuidv7 } from 'uuid';
import type { Prisma } from '@prisma/client';
import type { PrismaService } from '../../common/prisma.service';

export const SESSION_LOG = {
  booked: 'booked',
  cancelled: 'cancelled',
  cancelledOther: 'cancelled_other',
  checkedIn: 'checked_in',
} as const;

type LogWriter = Prisma.TransactionClient | PrismaService;

export function purgeEndedSessionLogs(prisma: PrismaService, studioId: string) {
  return prisma.sessionLog.deleteMany({
    where: { studioId, session: { endsAt: { lte: new Date() } } },
  });
}

export function writeSessionLog(
  db: LogWriter,
  input: {
    studioId: string;
    sessionId: string;
    actorId: string;
    targetId: string;
    action: string;
    comment?: string | null;
  },
) {
  const comment = input.comment?.trim() || null;
  return db.sessionLog.create({
    data: {
      id: uuidv7(),
      studioId: input.studioId,
      sessionId: input.sessionId,
      actorId: input.actorId,
      targetId: input.targetId,
      action: input.action,
      comment,
    },
  });
}
