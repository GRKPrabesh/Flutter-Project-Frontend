class Org {
  final String id;
  final String name;
  final String address;
  final String phone;

  Org({required this.id, required this.name, required this.address, required this.phone});

  factory Org.fromJson(Map<String, dynamic> j) => Org(
        id: j['_id']?.toString() ?? j['id'].toString(),
        name: j['name'] ?? '',
        address: j['address'] ?? '',
        phone: j['phone'] ?? '',
      );
}
