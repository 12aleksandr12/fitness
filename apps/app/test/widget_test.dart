import 'package:fitness_app/features/auth/data/auth_user.dart';
import 'package:fitness_app/core/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('permission check is independent of platform', () {
    final user = AuthUser(
      userId: '1',
      email: 'a@b.c',
      name: 'A',
      studioId: 's',
      roleId: 'r',
      roleName: 'Администратор',
      permissions: [Permissions.manageRoles, Permissions.bookSelf],
    );
    expect(user.can(Permissions.manageRoles), isTrue);
    expect(user.can(Permissions.adjustBalance), isFalse);
  });
}
