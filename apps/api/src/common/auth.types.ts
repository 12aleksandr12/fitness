import type { PermissionSlug } from './permissions';

export type AuthUser = {
  userId: string;
  email: string;
  name: string;
  studioId: string;
  membershipId: string;
  roleId: string;
  roleName: string;
  permissions: PermissionSlug[];
};
