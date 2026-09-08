import { HttpStatus, Injectable } from '@nestjs/common';
import { v7 as uuidv7 } from 'uuid';
import type { AuthUser } from '../../common/auth.types';
import { AppError } from '../../common/errors';
import { PERMISSION_SLUGS } from '../../common/permissions';
import { PrismaService } from '../../common/prisma.service';
import type { AssignRoleDto, CreateRoleDto, UpdateRoleDto } from './dto/role.dto';

@Injectable()
export class RolesService {
  constructor(private readonly prisma: PrismaService) {}

  listPermissions() {
    return this.prisma.permission.findMany({ orderBy: { slug: 'asc' } });
  }

  listRoles(studioId: string) {
    return this.prisma.role.findMany({
      where: { studioId },
      include: { permissions: { include: { permission: true } } },
      orderBy: { name: 'asc' },
    });
  }

  listForInviteOrManage(actor: AuthUser) {
    const can =
      actor.permissions.includes('manage_roles') || actor.permissions.includes('manage_users');
    if (!can) {
      throw new AppError(HttpStatus.FORBIDDEN, 'FORBIDDEN', 'Missing permission', {
        permission: 'manage_users',
      });
    }
    return this.listRoles(actor.studioId);
  }

  async create(actor: AuthUser, dto: CreateRoleDto) {
    const permissionIds = await this.resolvePermissionIds(dto.permissionSlugs);
    return this.prisma.role.create({
      data: {
        id: uuidv7(),
        studioId: actor.studioId,
        name: dto.name,
        isSystem: false,
        permissions: { create: permissionIds.map((permissionId) => ({ permissionId })) },
      },
      include: { permissions: { include: { permission: true } } },
    });
  }

  async update(actor: AuthUser, roleId: string, dto: UpdateRoleDto) {
    const role = await this.requireRole(actor.studioId, roleId);
    if (dto.permissionSlugs) {
      const permissionIds = await this.resolvePermissionIds(dto.permissionSlugs);
      if (role.isSystem && role.name === 'Администратор') {
        await this.assertNotStrippingLastManageRoles(actor.studioId, roleId, dto.permissionSlugs);
      }
      await this.prisma.$transaction([
        this.prisma.rolePermission.deleteMany({ where: { roleId } }),
        this.prisma.rolePermission.createMany({
          data: permissionIds.map((permissionId) => ({ roleId, permissionId })),
        }),
        ...(dto.name && !role.isSystem
          ? [this.prisma.role.update({ where: { id: roleId }, data: { name: dto.name } })]
          : []),
      ]);
    } else if (dto.name && !role.isSystem) {
      await this.prisma.role.update({ where: { id: roleId }, data: { name: dto.name } });
    }
    if (dto.name && role.isSystem) {
      throw new AppError(HttpStatus.BAD_REQUEST, 'SYSTEM_ROLE', 'Cannot rename a system role');
    }
    return this.prisma.role.findUniqueOrThrow({
      where: { id: roleId },
      include: { permissions: { include: { permission: true } } },
    });
  }

  async remove(actor: AuthUser, roleId: string) {
    const role = await this.requireRole(actor.studioId, roleId);
    if (role.isSystem) {
      throw new AppError(HttpStatus.BAD_REQUEST, 'SYSTEM_ROLE', 'Cannot delete a system role');
    }
    const used = await this.prisma.membership.count({ where: { roleId } });
    if (used > 0) {
      throw new AppError(HttpStatus.BAD_REQUEST, 'ROLE_IN_USE', 'Role is assigned to users');
    }
    await this.prisma.role.delete({ where: { id: roleId } });
    return { ok: true };
  }

  async assign(actor: AuthUser, userId: string, dto: AssignRoleDto) {
    const role = await this.requireRole(actor.studioId, dto.roleId);
    const membership = await this.prisma.membership.findFirst({
      where: { userId, studioId: actor.studioId },
    });
    if (!membership) {
      throw new AppError(HttpStatus.NOT_FOUND, 'MEMBERSHIP_NOT_FOUND', 'User is not in this studio');
    }
    await this.assertNotRemovingLastManageRoles(actor.studioId, membership, role.id);
    await this.prisma.membership.update({
      where: { id: membership.id },
      data: { roleId: role.id },
    });
    return { ok: true };
  }

  private async requireRole(studioId: string, roleId: string) {
    const role = await this.prisma.role.findFirst({ where: { id: roleId, studioId } });
    if (!role) {
      throw new AppError(HttpStatus.NOT_FOUND, 'ROLE_NOT_FOUND', 'Role not found');
    }
    return role;
  }

  private async resolvePermissionIds(slugs: string[]) {
    const unknown = slugs.filter((s) => !PERMISSION_SLUGS.includes(s as never));
    if (unknown.length > 0) {
      throw new AppError(HttpStatus.BAD_REQUEST, 'UNKNOWN_PERMISSION', 'Unknown permission slug', {
        unknown,
      });
    }
    const rows = await this.prisma.permission.findMany({ where: { slug: { in: slugs } } });
    return rows.map((p) => p.id);
  }

  private async assertNotStrippingLastManageRoles(
    studioId: string,
    roleId: string,
    slugs: string[],
  ) {
    if (slugs.includes('manage_roles')) {
      return;
    }
    const others = await this.countManageRoles(studioId, roleId);
    if (others === 0) {
      throw new AppError(
        HttpStatus.BAD_REQUEST,
        'LAST_MANAGE_ROLES',
        'Cannot leave the studio without manage_roles',
      );
    }
  }

  private async assertNotRemovingLastManageRoles(
    studioId: string,
    membership: { id: string; roleId: string },
    newRoleId: string,
  ) {
    const currentHas = await this.roleHasManageRoles(membership.roleId);
    const nextHas = await this.roleHasManageRoles(newRoleId);
    if (!currentHas || nextHas) {
      return;
    }
    const others = await this.prisma.membership.count({
      where: {
        studioId,
        id: { not: membership.id },
        role: { permissions: { some: { permission: { slug: 'manage_roles' } } } },
      },
    });
    if (others === 0) {
      throw new AppError(
        HttpStatus.BAD_REQUEST,
        'LAST_MANAGE_ROLES',
        'Cannot leave the studio without manage_roles',
      );
    }
  }

  private async roleHasManageRoles(roleId: string) {
    const n = await this.prisma.rolePermission.count({
      where: { roleId, permission: { slug: 'manage_roles' } },
    });
    return n > 0;
  }

  private async countManageRoles(studioId: string, excludeRoleId: string) {
    return this.prisma.membership.count({
      where: {
        studioId,
        roleId: { not: excludeRoleId },
        role: { permissions: { some: { permission: { slug: 'manage_roles' } } } },
      },
    });
  }
}
