export const PERMISSION_SLUGS = [
  'manage_roles',
  'manage_schedule',
  'book_self',
  'book_others',
  'check_in',
  'adjust_balance',
  'manage_users',
  'view_clients',
] as const;

export type PermissionSlug = (typeof PERMISSION_SLUGS)[number];
