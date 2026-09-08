class AuthUser {
  AuthUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.studioId,
    required this.roleId,
    required this.roleName,
    required this.permissions,
    this.hasPhoto = false,
  });

  final String userId;
  final String email;
  final String name;
  final String studioId;
  final String roleId;
  final String roleName;
  final List<String> permissions;
  final bool hasPhoto;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      studioId: json['studioId'] as String,
      roleId: json['roleId'] as String,
      roleName: json['roleName'] as String,
      permissions: (json['permissions'] as List<dynamic>).cast<String>(),
      hasPhoto: json['hasPhoto'] == true,
    );
  }

  bool can(String slug) => permissions.contains(slug);
}
