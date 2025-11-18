class ServiceItem {
  final String id;
  final String orgId;
  final String title;
  final int price;

  ServiceItem({required this.id, required this.orgId, required this.title, required this.price});

  factory ServiceItem.fromJson(Map<String, dynamic> j) => ServiceItem(
        id: j['_id']?.toString() ?? j['id'].toString(),
        orgId: j['orgId']?.toString() ?? '',
        title: j['title'] ?? j['name'] ?? '',
        price: (j['price'] is num) ? (j['price'] as num).toInt() : int.tryParse('${j['price']}') ?? 0,
      );
}
