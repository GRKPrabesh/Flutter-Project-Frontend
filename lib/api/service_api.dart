import '../models/org.dart';
import '../models/service.dart';
import '../models/booking.dart';
import 'client.dart';

class ServiceApi {
  final ApiClient _c;
  ServiceApi({ApiClient? client}) : _c = client ?? ApiClient();

  Future<List<Org>> fetchOrgs() async {
    final list = await _c.getJsonList('/orgs');
    return list.map((e) => Org.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ServiceItem>> fetchServicesByOrg(String orgId) async {
    final list = await _c.getJsonList('/orgs/$orgId/services');
    return list.map((e) => ServiceItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Booking> createBooking({required String serviceId, required DateTime date, required String address, required String contact}) async {
    final res = await _c.postJson('/bookings', {
      'serviceId': serviceId,
      'date': date.toIso8601String(),
      'address': address,
      'contact': contact,
    });
    return Booking.fromJson(res);
  }

  Future<List<Booking>> fetchBookings() async {
    final list = await _c.getJsonList('/bookings');
    return list.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }
}
