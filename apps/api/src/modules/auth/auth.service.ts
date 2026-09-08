import { createHash, randomBytes } from 'crypto';
import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { v7 as uuidv7 } from 'uuid';
import { AppError } from '../../common/errors';
import type { AuthUser } from '../../common/auth.types';
import { PrismaService } from '../../common/prisma.service';
import { MailService } from '../studio/mail.service';
import type { InviteDto, LoginDto, RegisterDto } from './dto/auth.dto';

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly mail: MailService,
  ) {}

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (!user || !(await argon2.verify(user.passwordHash, dto.password))) {
      throw new AppError(HttpStatus.UNAUTHORIZED, 'INVALID_CREDENTIALS', 'Invalid email or password');
    }
    return this.issueTokens(user.id);
  }

  async refresh(refreshToken: string) {
    const tokenHash = hashToken(refreshToken);
    const row = await this.prisma.refreshToken.findUnique({ where: { tokenHash } });
    if (!row || row.revokedAt || row.expiresAt < new Date()) {
      throw new AppError(HttpStatus.UNAUTHORIZED, 'INVALID_REFRESH', 'Refresh token is invalid');
    }
    await this.prisma.refreshToken.update({
      where: { id: row.id },
      data: { revokedAt: new Date() },
    });
    return this.issueTokens(row.userId);
  }

  async logout(refreshToken: string): Promise<void> {
    const tokenHash = hashToken(refreshToken);
    await this.prisma.refreshToken.updateMany({
      where: { tokenHash, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async invite(actor: AuthUser, dto: InviteDto) {
    const role = await this.prisma.role.findFirst({
      where: { id: dto.roleId, studioId: actor.studioId },
    });
    if (!role) {
      throw new AppError(HttpStatus.NOT_FOUND, 'ROLE_NOT_FOUND', 'Role not found');
    }
    const token = randomBytes(32).toString('hex');
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);
    await this.prisma.invite.create({
      data: {
        id: uuidv7(),
        studioId: actor.studioId,
        roleId: role.id,
        email: dto.email,
        tokenHash: hashToken(token),
        expiresAt,
      },
    });
    await this.mail.send(
      dto.email,
      'Приглашение в Fitness',
      `Вас пригласили в студию. Откройте Регистрацию и вставьте токен:\n${token}`,
    );
    return { ok: true, token };
  }

  async register(dto: RegisterDto) {
    const tokenHash = hashToken(dto.token);
    const invite = await this.prisma.invite.findUnique({ where: { tokenHash } });
    if (!invite || invite.usedAt || invite.expiresAt < new Date()) {
      throw new AppError(HttpStatus.BAD_REQUEST, 'INVALID_INVITE', 'Invite is invalid');
    }
    const existing = await this.prisma.user.findUnique({ where: { email: invite.email } });
    if (existing) {
      throw new AppError(HttpStatus.CONFLICT, 'EMAIL_TAKEN', 'Email already registered');
    }
    const userId = uuidv7();
    await this.prisma.$transaction([
      this.prisma.user.create({
        data: {
          id: userId,
          email: invite.email,
          name: dto.name,
          passwordHash: await argon2.hash(dto.password),
        },
      }),
      this.prisma.membership.create({
        data: {
          id: uuidv7(),
          userId,
          studioId: invite.studioId,
          roleId: invite.roleId,
        },
      }),
      this.prisma.invite.update({
        where: { id: invite.id },
        data: { usedAt: new Date() },
      }),
    ]);
    return this.issueTokens(userId);
  }

  private async issueTokens(userId: string) {
    const accessToken = await this.jwt.signAsync({ sub: userId });
    const refreshToken = randomBytes(48).toString('hex');
    const days = Number(this.config.get('JWT_REFRESH_TTL_DAYS') ?? 30);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + days);
    await this.prisma.refreshToken.create({
      data: {
        id: uuidv7(),
        userId,
        tokenHash: hashToken(refreshToken),
        expiresAt,
      },
    });
    return { accessToken, refreshToken };
  }
}
