enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final String serviceTitle;
  final String orgName;
  final DateTime date;
  final String? time;
  final int durationDays;
  final DateTime? endDate;
  final int price;
  final BookingStatus status;
  final Map<String, dynamic>? assignedGuard;

  Booking({
    required this.id,
    required this.serviceTitle,
    required this.orgName,
    required this.date,
    this.time,
    this.durationDays = 1,
    this.endDate,
    required this.price,
    required this.status,
    this.assignedGuard,
  });

  /// Map backend Booking (with populated relations) to UI model.
  /// Backend booking list populates: serviceId, organizationId, userId, assignedStaffId.
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: (j['_id'] ?? j['id']).toString(),
        serviceTitle: (j['serviceTitle'] ?? j['serviceId']?['name'] ?? '').toString(),
        orgName: (j['orgName'] ?? j['organizationId']?['companyName'] ?? '').toString(),
        date: DateTime.tryParse(j['requiredDate']?.toString() ?? '') ?? DateTime.now(),
        time: j['requiredTime']?.toString(),
        durationDays: (j['durationDays'] is num) ? (j['durationDays'] as num).toInt() : 1,
        endDate: j['endDate'] != null ? DateTime.tryParse(j['endDate']?.toString() ?? '') : null,
        price: (j['price'] is num)
            ? (j['price'] as num).toInt()
            : (j['serviceId']?['price'] is num)
                ? (j['serviceId']['price'] as num).toInt()
                : int.tryParse('${j['price'] ?? j['serviceId']?['price']}') ?? 0,
        status: _statusFrom(j['status']),
        assignedGuard: j['assignedStaffId'] != null 
            ? (j['assignedStaffId'] is Map<String, dynamic> 
                ? j['assignedStaffId'] as Map<String, dynamic>
                : {})
            : null,
      );
}

BookingStatus _statusFrom(dynamic s) {
  final v = (s?.toString() ?? '').toLowerCase();
  if (v.startsWith('confirm')) return BookingStatus.confirmed;
  if (v.startsWith('cancel')) return BookingStatus.cancelled;
  if (v.startsWith('complete')) return BookingStatus.completed;
  return BookingStatus.pending;
}
