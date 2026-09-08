import { SetMetadata } from '@nestjs/common';
import type { PermissionSlug } from './permissions';

export const PERMISSION_KEY = 'permission';

export const RequirePermission = (slug: PermissionSlug) => SetMetadata(PERMISSION_KEY, slug);
