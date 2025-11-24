enum UserRole { admin, seeker, organization }

class AppUser {
  final String id;
  final String emailOrUsername;
  final String password;
  final UserRole role;
  final String displayName;
  final Map<String, dynamic> meta;

  const AppUser({
    required this.id,
    required this.emailOrUsername,
    required this.password,
    required this.role,
    required this.displayName,
    this.meta = const {},
  });

  AppUser copyWith({
    String? id,
    String? emailOrUsername,
    String? password,
    UserRole? role,
    String? displayName,
    Map<String, dynamic>? meta,
  }) {
    return AppUser(
      id: id ?? this.id,
      emailOrUsername: emailOrUsername ?? this.emailOrUsername,
      password: password ?? this.password,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      meta: meta ?? this.meta,
    );
  }
}

