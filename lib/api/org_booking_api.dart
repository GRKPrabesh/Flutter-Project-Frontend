import 'client.dart';

/// Organization Booking API for managing orders/bookings
class OrgBookingApi {
  final ApiClient _c;
  OrgBookingApi({ApiClient? client}) : _c = client ?? ApiClient();

  /// Get all bookings/orders for the logged-in organization
  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final list = await _c.getJsonList('/api/org/booking');
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Accept/confirm a booking (automatically assigns guard if available)
  Future<Map<String, dynamic>> acceptBooking(String bookingId) async {
    return _c.putJson('/api/org/booking/$bookingId/accept', {});
  }

  /// Assign a guard to a booking
  Future<Map<String, dynamic>> assignGuard({
    required String bookingId,
    required String staffId,
  }) async {
    return _c.putJson('/api/org/booking/$bookingId/assign', {
      'staffId': staffId,
    });
  }

  /// Cancel a booking
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    return _c.putJson('/api/org/booking/$bookingId/cancel', {});
  }
}

