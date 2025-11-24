import 'client.dart';

/// Staff/Guard API for organizations to manage their guards
class StaffApi {
  final ApiClient _c;
  StaffApi({ApiClient? client}) : _c = client ?? ApiClient();

  /// Get all staff/guards for the logged-in organization
  Future<List<Map<String, dynamic>>> fetchStaff() async {
    final list = await _c.getJsonList('/api/staff');
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Create a new staff member/guard
  Future<Map<String, dynamic>> createStaff({
    required String name,
    required String email,
    required String phone,
    String? experience,
    String? profilePic,
  }) async {
    return _c.postJson('/api/staff', {
      'name': name,
      'email': email,
      'phone': phone,
      if (experience != null) 'experience': experience,
      if (profilePic != null) 'profilePic': profilePic,
    });
  }

  /// Update a staff member/guard
  Future<Map<String, dynamic>> updateStaff({
    required String staffId,
    String? name,
    String? email,
    String? phone,
    String? experience,
    String? status,
  }) async {
    return _c.putJson('/api/staff/$staffId', {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (experience != null) 'experience': experience,
      if (status != null) 'status': status,
    });
  }

  /// Delete a staff member/guard
  Future<void> deleteStaff(String staffId) async {
    await _c.deleteJson('/api/staff/$staffId');
  }

  /// Deactivate a staff member (set status to inactive)
  Future<Map<String, dynamic>> deactivateStaff(String staffId) async {
    return _c.putJson('/api/staff/$staffId/deactivate', {});
  }
}

