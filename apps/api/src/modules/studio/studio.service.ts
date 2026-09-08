import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';

@Injectable()
export class StudioService {
  constructor(private readonly prisma: PrismaService) {}

  current(studioId: string) {
    return this.prisma.studio.findUniqueOrThrow({ where: { id: studioId } });
  }
}
