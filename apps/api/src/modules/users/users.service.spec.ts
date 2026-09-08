import { canEditProfile, sniffImage } from './users.service';
import type { AuthUser } from '../../common/auth.types';

function actor(overrides: Partial<AuthUser>): AuthUser {
  return {
    userId: 'admin-id',
    email: 'admin@fitness.local',
    name: 'Админ',
    hasPhoto: false,
    studioId: 'studio-id',
    membershipId: 'mem-id',
    roleId: 'role-id',
    roleName: 'Администратор',
    permissions: [],
    ...overrides,
  };
}

describe('canEditProfile', () => {
  it('allows a user to edit themselves', () => {
    expect(canEditProfile(actor({ userId: 'u1', permissions: [] }), 'u1')).toBe(true);
  });

  it('allows manage_users to edit someone else', () => {
    expect(canEditProfile(actor({ permissions: ['manage_users'] }), 'other')).toBe(true);
  });

  it('blocks editing others without manage_users', () => {
    expect(canEditProfile(actor({ permissions: ['view_clients'] }), 'other')).toBe(false);
  });
});

describe('sniffImage', () => {
  it('accepts jpeg, png and webp magic bytes', () => {
    const jpeg = Buffer.from([0xff, 0xd8, 0xff, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    const png = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0, 0, 0, 0, 0, 0, 0, 0]);
    const webp = Buffer.from('RIFF....WEBP');
    expect(sniffImage(jpeg)).toBe('jpg');
    expect(sniffImage(png)).toBe('png');
    expect(sniffImage(webp)).toBe('webp');
  });

  it('rejects empty and unknown bytes', () => {
    expect(sniffImage(Buffer.from('not-an-image!!'))).toBeNull();
    expect(sniffImage(Buffer.from([1, 2, 3]))).toBeNull();
  });
});
