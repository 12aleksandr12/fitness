import { mkdir, readFile, unlink, writeFile } from 'fs/promises';
import { join } from 'path';
import { HttpStatus, Injectable } from '@nestjs/common';
import type { AuthUser } from '../../common/auth.types';
import { AppError } from '../../common/errors';
import { PrismaService } from '../../common/prisma.service';
import type { UpdateProfileDto } from './dto/user.dto';

export const MAX_PHOTO_BYTES = 512 * 1024;

const MIME: Record<string, string> = {
  jpg: 'image/jpeg',
  png: 'image/png',
  webp: 'image/webp',
};

export function canEditProfile(actor: AuthUser, userId: string): boolean {
  return actor.userId === userId || actor.permissions.includes('manage_users');
}

export function sniffImage(buf: Buffer): keyof typeof MIME | null {
  if (buf.length < 12) {
    return null;
  }
  if (buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff) {
    return 'jpg';
  }
  if (buf[0] === 0x89 && buf[1] === 0x50 && buf[2] === 0x4e && buf[3] === 0x47) {
    return 'png';
  }
  if (buf.toString('ascii', 0, 4) === 'RIFF' && buf.toString('ascii', 8, 12) === 'WEBP') {
    return 'webp';
  }
  return null;
}

type UserRow = {
  id: string;
  email: string;
  name: string;
  phone: string | null;
  bio: string | null;
  photoExt: string | null;
};

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  private uploadsDir() {
    return process.env.UPLOADS_DIR ?? join(process.cwd(), 'uploads');
  }

  private photoPath(userId: string, ext: string) {
    return join(this.uploadsDir(), 'avatars', `${userId}.${ext}`);
  }

  private canSeePrivate(actor: AuthUser, userId: string) {
    return (
      actor.userId === userId ||
      actor.permissions.includes('view_clients') ||
      actor.permissions.includes('manage_users')
    );
  }

  private async requireEditableMember(actor: AuthUser, userId: string) {
    if (!canEditProfile(actor, userId)) {
      throw new AppError(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Missing permission');
    }
    const membership = await this.prisma.membership.findFirst({
      where: { studioId: actor.studioId, userId },
      select: { id: true },
    });
    if (!membership) {
      throw new AppError(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'User not found');
    }
  }

  private toProfile(actor: AuthUser, user: UserRow, roleName: string) {
    const privateFields = this.canSeePrivate(actor, user.id);
    return {
      id: user.id,
      name: user.name,
      bio: user.bio,
      hasPhoto: Boolean(user.photoExt),
      roleName,
      ...(privateFields ? { email: user.email, phone: user.phone } : {}),
    };
  }

  async list(actor: AuthUser) {
    const rows = await this.prisma.membership.findMany({
      where: { studioId: actor.studioId },
      include: {
        user: { select: { id: true, email: true, name: true, phone: true, bio: true, photoExt: true } },
        role: { select: { id: true, name: true } },
      },
      orderBy: { user: { name: 'asc' } },
    });
    return rows.map((m) => ({
      id: m.id,
      role: m.role,
      user: this.toProfile(actor, m.user, m.role.name),
    }));
  }

  async one(actor: AuthUser, userId: string) {
    const membership = await this.prisma.membership.findFirst({
      where: { studioId: actor.studioId, userId },
      include: {
        user: { select: { id: true, email: true, name: true, phone: true, bio: true, photoExt: true } },
        role: { select: { id: true, name: true } },
      },
    });
    if (!membership) {
      throw new AppError(HttpStatus.NOT_FOUND, 'USER_NOT_FOUND', 'User not found');
    }
    return this.toProfile(actor, membership.user, membership.role.name);
  }

  me(actor: AuthUser) {
    return this.one(actor, actor.userId);
  }

  async updateProfile(actor: AuthUser, userId: string, dto: UpdateProfileDto) {
    await this.requireEditableMember(actor, userId);
    const data: { name?: string; phone?: string | null; bio?: string | null } = {};
    if (dto.name !== undefined) {
      data.name = dto.name.trim();
    }
    if (dto.phone !== undefined) {
      data.phone = dto.phone.trim() === '' ? null : dto.phone.trim();
    }
    if (dto.bio !== undefined) {
      data.bio = dto.bio.trim() === '' ? null : dto.bio.trim();
    }
    await this.prisma.user.update({ where: { id: userId }, data });
    return this.one(actor, userId);
  }

  async savePhoto(actor: AuthUser, userId: string, buf: Buffer) {
    await this.requireEditableMember(actor, userId);
    if (buf.length > MAX_PHOTO_BYTES) {
      throw new AppError(HttpStatus.BAD_REQUEST, 'PHOTO_TOO_LARGE', 'Photo must be 512 KB or smaller');
    }
    const ext = sniffImage(buf);
    if (!ext) {
      throw new AppError(HttpStatus.BAD_REQUEST, 'PHOTO_TYPE', 'Only JPEG, PNG or WebP photos are allowed');
    }
    const current = await this.prisma.user.findUnique({ where: { id: userId } });
    await mkdir(join(this.uploadsDir(), 'avatars'), { recursive: true });
    if (current?.photoExt && current.photoExt !== ext) {
      await unlink(this.photoPath(userId, current.photoExt)).catch(() => undefined);
    }
    await writeFile(this.photoPath(userId, ext), buf);
    await this.prisma.user.update({ where: { id: userId }, data: { photoExt: ext } });
    return this.one(actor, userId);
  }

  async deletePhoto(actor: AuthUser, userId: string) {
    await this.requireEditableMember(actor, userId);
    const current = await this.prisma.user.findUnique({ where: { id: userId } });
    if (current?.photoExt) {
      await unlink(this.photoPath(userId, current.photoExt)).catch(() => undefined);
      await this.prisma.user.update({ where: { id: userId }, data: { photoExt: null } });
    }
    return this.one(actor, userId);
  }

  async photoFile(actor: AuthUser, userId: string): Promise<{ buf: Buffer; mime: string }> {
    const id = userId === 'me' ? actor.userId : userId;
    const membership = await this.prisma.membership.findFirst({
      where: { studioId: actor.studioId, userId: id },
      include: { user: { select: { photoExt: true } } },
    });
    if (!membership?.user.photoExt) {
      throw new AppError(HttpStatus.NOT_FOUND, 'PHOTO_NOT_FOUND', 'Photo not found');
    }
    const ext = membership.user.photoExt;
    if (!(ext in MIME)) {
      throw new AppError(HttpStatus.NOT_FOUND, 'PHOTO_NOT_FOUND', 'Photo not found');
    }
    try {
      const buf = await readFile(this.photoPath(id, ext));
      return { buf, mime: MIME[ext] };
    } catch {
      await this.prisma.user.update({ where: { id }, data: { photoExt: null } }).catch(() => undefined);
      throw new AppError(HttpStatus.NOT_FOUND, 'PHOTO_NOT_FOUND', 'Photo not found');
    }
  }
}
