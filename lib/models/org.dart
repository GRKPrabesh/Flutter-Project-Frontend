class Org {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;

  Org({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  /// Map backend Org model to UI model.
  /// Backend Org fields: _id, companyName, address, profilePic, user (populated with name, email, phone, role).
  factory Org.fromJson(Map<String, dynamic> j) {
    final user = j['user'] as Map<String, dynamic>?;
    return Org(
      id: (j['_id'] ?? j['id']).toString(),
      name: (j['companyName'] ?? user?['name'] ?? '').toString(),
      address: (j['address'] ?? '').toString(),
      phone: (user?['phone'] ?? '').toString(),
      email: (user?['email'] ?? '').toString(),
    );
  }
}
