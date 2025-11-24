import 'client.dart';

/// Admin API for viewing all organizations, guards, and orders
class AdminApi {
  final ApiClient _c;
  AdminApi({ApiClient? client}) : _c = client ?? ApiClient();

  /// Get all organizations
  Future<List<Map<String, dynamic>>> fetchOrganizations() async {
    final list = await _c.getJsonList('/api/admin/org');
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get all staff/guards for a specific organization
  Future<List<Map<String, dynamic>>> fetchOrgStaff(String orgId) async {
    final list = await _c.getJsonList('/api/admin/org/$orgId/staff');
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Get all bookings/orders
  Future<List<Map<String, dynamic>>> fetchAllBookings() async {
    final list = await _c.getJsonList('/api/admin/booking');
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}

