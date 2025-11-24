import 'dart:math';

import '../models/app_user.dart';

class AppUserRepository {
  AppUserRepository._();

  static final AppUserRepository instance = AppUserRepository._();

  final List<AppUser> _users = [
    const AppUser(
      id: 'admin',
      emailOrUsername: 'admin',
      password: 'admin',
      role: UserRole.admin,
      displayName: 'System Admin',
      meta: {
        'email': 'admin@protego.com',
      },
    ),
  ];

  final List<Map<String, String>> _guards = [
    {
      'name': 'Raju Sharma',
      'experience': '5 yrs',
      'shift': 'Night Patrol',
    },
    {
      'name': 'Anita Thapa',
      'experience': '3 yrs',
      'shift': 'CCTV Monitoring',
    },
    {
      'name': 'Kisan Gurung',
      'experience': '7 yrs',
      'shift': 'Industrial Security',
    },
  ];

  final List<Map<String, String>> _organizations = [
    {
      'company': 'Kathmandu Security House',
      'owner': 'Madan Bista',
      'address': 'Kalimati, Kathmandu',
    },
    {
      'company': 'Lalitpur Elite Guards',
      'owner': 'Anju Maskey',
      'address': 'Pulchowk, Lalitpur',
    },
  ];

  List<AppUser> get seekers =>
      _users.where((user) => user.role == UserRole.seeker).toList();

  List<AppUser> get organizationsUsers =>
      _users.where((user) => user.role == UserRole.organization).toList();

  List<Map<String, String>> get guards => List.unmodifiable(_guards);

  List<Map<String, String>> get organizations =>
      List.unmodifiable(_organizations);

  AppUser? login(String identifier, String password) {
    final lowerId = identifier.trim().toLowerCase();
    try {
      return _users.firstWhere(
        (user) =>
            user.emailOrUsername.toLowerCase() == lowerId &&
            user.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  AppUser registerSeeker({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) {
    _ensureUniqueEmail(email);
    final user = AppUser(
      id: _generateId(),
      emailOrUsername: email.trim(),
      password: password,
      role: UserRole.seeker,
      displayName: '$firstName $lastName'.trim(),
      meta: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      },
    );
    _users.add(user);
    return user;
  }

  AppUser registerOrganization({
    required String email,
    required String password,
    required String companyName,
    required String owner,
    required String address,
    required String registrationId,
  }) {
    _ensureUniqueEmail(email);
    final user = AppUser(
      id: _generateId(),
      emailOrUsername: email.trim(),
      password: password,
      role: UserRole.organization,
      displayName: companyName.trim(),
      meta: {
        'owner': owner,
        'address': address,
        'registrationId': registrationId,
      },
    );
    _users.add(user);
    _organizations.add({
      'company': companyName,
      'owner': owner,
      'address': address,
    });
    return user;
  }

  void _ensureUniqueEmail(String email) {
    final exists = _users.any(
      (user) => user.emailOrUsername.toLowerCase() == email.trim().toLowerCase(),
    );
    if (exists) {
      throw StateError('Account already exists for $email');
    }
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(999).toString().padLeft(3, '0');
}

