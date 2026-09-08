import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';
import { v7 as uuidv7 } from 'uuid';

const prisma = new PrismaClient();

const PERMISSIONS: { slug: string; name: string }[] = [
  { slug: 'manage_roles', name: 'Управление ролями' },
  { slug: 'manage_schedule', name: 'Управление расписанием' },
  { slug: 'book_self', name: 'Запись себя' },
  { slug: 'book_others', name: 'Запись клиентов' },
  { slug: 'check_in', name: 'Отметка визита' },
  { slug: 'adjust_balance', name: 'Корректировка баланса' },
  { slug: 'manage_users', name: 'Управление пользователями' },
  { slug: 'view_clients', name: 'Просмотр клиентов' },
];

async function main() {
  const existing = await prisma.studio.findFirst();
  if (existing) {
    return;
  }

  const passwordHash = await argon2.hash('Password123!');
  const studioId = uuidv7();
  const adminUserId = uuidv7();
  const trainerUserId = uuidv7();
  const clientUserId = uuidv7();
  const adminRoleId = uuidv7();
  const trainerRoleId = uuidv7();
  const clientRoleId = uuidv7();
  const yogaId = uuidv7();
  const strengthId = uuidv7();

  await prisma.studio.create({
    data: { id: studioId, name: 'Fitness Studio' },
  });

  const permRows = [];
  for (const p of PERMISSIONS) {
    const row = await prisma.permission.create({
      data: { id: uuidv7(), slug: p.slug, name: p.name },
    });
    permRows.push(row);
  }
  const slugs = Object.fromEntries(permRows.map((p) => [p.slug, p.id]));

  await prisma.role.createMany({
    data: [
      { id: adminRoleId, studioId, name: 'Администратор', isSystem: true },
      { id: trainerRoleId, studioId, name: 'Тренер', isSystem: true },
      { id: clientRoleId, studioId, name: 'Участник', isSystem: true },
    ],
  });

  await prisma.rolePermission.createMany({
    data: PERMISSIONS.map((p) => ({
      roleId: adminRoleId,
      permissionId: slugs[p.slug],
    })),
  });
  await prisma.rolePermission.createMany({
    data: ['manage_schedule', 'check_in', 'view_clients', 'book_self'].map((slug) => ({
      roleId: trainerRoleId,
      permissionId: slugs[slug],
    })),
  });
  await prisma.rolePermission.createMany({
    data: ['book_self'].map((slug) => ({
      roleId: clientRoleId,
      permissionId: slugs[slug],
    })),
  });

  await prisma.user.createMany({
    data: [
      { id: adminUserId, email: 'admin@fitness.local', passwordHash, name: 'Админ' },
      { id: trainerUserId, email: 'trainer@fitness.local', passwordHash, name: 'Тренер' },
      { id: clientUserId, email: 'client@fitness.local', passwordHash, name: 'Участник' },
    ],
  });

  await prisma.membership.createMany({
    data: [
      { id: uuidv7(), userId: adminUserId, studioId, roleId: adminRoleId },
      { id: uuidv7(), userId: trainerUserId, studioId, roleId: trainerRoleId },
      { id: uuidv7(), userId: clientUserId, studioId, roleId: clientRoleId },
    ],
  });

  await prisma.classType.createMany({
    data: [
      { id: yogaId, studioId, name: 'Йога' },
      { id: strengthId, studioId, name: 'Силовая' },
    ],
  });

  const start = new Date();
  start.setUTCDate(start.getUTCDate() + ((1 + 7 - start.getUTCDay()) % 7 || 7));
  start.setUTCHours(8, 0, 0, 0);

  const sessions = [];
  for (let day = 0; day < 5; day++) {
    for (const hour of [8, 10, 18]) {
      const startsAt = new Date(start);
      startsAt.setUTCDate(start.getUTCDate() + day);
      startsAt.setUTCHours(hour, 0, 0, 0);
      const endsAt = new Date(startsAt);
      endsAt.setUTCHours(hour + 1, 0, 0, 0);
      sessions.push({
        id: uuidv7(),
        studioId,
        classTypeId: hour === 8 ? yogaId : strengthId,
        trainerId: trainerUserId,
        room: 'Зал 1',
        startsAt,
        endsAt,
        capacity: 8,
      });
    }
  }
  await prisma.session.createMany({ data: sessions });

  const passUntil = new Date();
  passUntil.setUTCMonth(passUntil.getUTCMonth() + 2);
  await prisma.pass.create({
    data: {
      id: uuidv7(),
      studioId,
      userId: clientUserId,
      name: '8 визитов',
      remainingVisits: 8,
      validFrom: new Date(),
      validUntil: passUntil,
    },
  });
  await prisma.ledgerEntry.create({
    data: {
      id: uuidv7(),
      studioId,
      userId: clientUserId,
      createdById: adminUserId,
      type: 'credit',
      visits: 8,
      note: 'Стартовый абонемент',
    },
  });
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
