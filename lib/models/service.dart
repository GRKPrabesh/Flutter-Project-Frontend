class ServiceItem {
  final String id;
  final String orgId;
  final String title;
  final int price;

  ServiceItem({required this.id, required this.orgId, required this.title, required this.price});

  factory ServiceItem.fromJson(Map<String, dynamic> j) => ServiceItem(
        id: (j['_id'] ?? j['id']).toString(),
        // Backend model uses organizationId
        orgId: (j['organizationId'] ?? j['orgId'] ?? '').toString(),
        // Backend service field is "name"
        title: (j['name'] ?? j['title'] ?? '').toString(),
        price: (j['price'] is num) ? (j['price'] as num).toInt() : int.tryParse('${j['price']}') ?? 0,
      );

  // Implement equality based on ID to fix DropdownButton comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
