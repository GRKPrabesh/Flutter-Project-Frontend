import '../models/org.dart';
import '../models/service.dart';
import '../models/booking.dart';
import 'client.dart';

/// Service & booking related APIs for customer side.
class ServiceApi {
  final ApiClient _c;
  ServiceApi({ApiClient? client}) : _c = client ?? ApiClient();

  /// List all organizations (public).
  Future<List<Org>> fetchOrgs() async {
    // Backend: GET /api/org
    final list = await _c.getJsonList('/api/org');
    return list
        .map((e) => Org.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// List all active services for a given organization (public).
  Future<List<ServiceItem>> fetchServicesByOrg(String orgId) async {
    // Backend: GET /api/service/org/:orgId
    final list = await _c.getJsonList('/api/service/org/$orgId');
    return list
        .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a booking for the logged-in user.
  Future<Booking> createBooking({
    required String serviceId,
    required DateTime date,
    required String time,
    required int durationDays,
    required String address,
    required String contact,
  }) async {
    // Backend expects: serviceId, requiredDate, requiredTime, durationDays, contact, address
    final res = await _c.postJson('/api/booking', {
      'serviceId': serviceId,
      'requiredDate': date.toIso8601String(),
      'requiredTime': time,
      'durationDays': durationDays,
      'address': address,
      'contact': contact,
    });
    return Booking.fromJson(res);
  }

  /// List bookings for the logged-in user.
  Future<List<Booking>> fetchBookings() async {
    // Backend: GET /api/booking
    final list = await _c.getJsonList('/api/booking');
    return list
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}


