enum BookingStatus { pending, confirmed, cancelled }

class Booking {
  final String id;
  final String serviceTitle;
  final String orgName;
  final DateTime date;
  final int price;
  final BookingStatus status;

  Booking({required this.id, required this.serviceTitle, required this.orgName, required this.date, required this.price, required this.status});

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['_id']?.toString() ?? j['id'].toString(),
        serviceTitle: j['serviceTitle'] ?? j['service']?['title'] ?? '',
        orgName: j['orgName'] ?? j['org']?['name'] ?? '',
        date: DateTime.tryParse(j['date'] ?? j['scheduledAt'] ?? '') ?? DateTime.now(),
        price: (j['price'] is num) ? (j['price'] as num).toInt() : int.tryParse('${j['price']}') ?? 0,
        status: _statusFrom(j['status']),
      );
}

BookingStatus _statusFrom(dynamic s) {
  final v = (s?.toString() ?? '').toLowerCase();
  if (v.startsWith('confirm')) return BookingStatus.confirmed;
  if (v.startsWith('cancel')) return BookingStatus.cancelled;
  return BookingStatus.pending;
}
