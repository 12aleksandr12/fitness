import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AppError } from './errors';
import { HttpStatus } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import type { AuthUser } from './auth.types';
import type { PermissionSlug } from './permissions';

type JwtPayload = { sub: string };

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.getOrThrow<string>('JWT_SECRET'),
    });
  }

  async validate(payload: JwtPayload): Promise<AuthUser> {
    const membership = await this.prisma.membership.findFirst({
      where: { userId: payload.sub },
      include: {
        user: true,
        role: { include: { permissions: { include: { permission: true } } } },
      },
    });
    if (!membership) {
      throw new AppError(HttpStatus.UNAUTHORIZED, 'UNAUTHORIZED', 'Unknown user');
    }
    return {
      userId: membership.userId,
      email: membership.user.email,
      name: membership.user.name,
      studioId: membership.studioId,
      membershipId: membership.id,
      roleId: membership.roleId,
      roleName: membership.role.name,
      permissions: membership.role.permissions.map((p) => p.permission.slug as PermissionSlug),
    };
  }
}
