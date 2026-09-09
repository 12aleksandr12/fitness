class Permissions {
  static const manageRoles = 'manage_roles';
  static const manageSchedule = 'manage_schedule';
  static const bookSelf = 'book_self';
  static const bookOthers = 'book_others';
  static const checkIn = 'check_in';
  static const adjustBalance = 'adjust_balance';
  static const manageUsers = 'manage_users';
  static const viewClients = 'view_clients';
}

enum PermissionGroup {
  schedule,
  booking,
  clients,
  ledger,
  roles;

  List<String> get slugs => switch (this) {
    PermissionGroup.schedule => const [Permissions.manageSchedule],
    PermissionGroup.booking => const [
      Permissions.bookSelf,
      Permissions.bookOthers,
      Permissions.checkIn,
    ],
    PermissionGroup.clients => const [Permissions.viewClients, Permissions.manageUsers],
    PermissionGroup.ledger => const [Permissions.adjustBalance],
    PermissionGroup.roles => const [Permissions.manageRoles],
  };
}
