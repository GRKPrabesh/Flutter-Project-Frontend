import 'client.dart';

/// Organization Service API for managing organization services
class OrgServiceApi {
  final ApiClient _c;
  OrgServiceApi({ApiClient? client}) : _c = client ?? ApiClient();

  /// Get all services for the logged-in organization
  Future<List<Map<String, dynamic>>> fetchServices() async {
    final list = await _c.getJsonList('/api/service');
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Create a new service
  Future<Map<String, dynamic>> createService({
    required String name,
    required double price,
    required String serviceTypeId,
    String? description,
    String? status,
    double? hourlyRate,
  }) async {
    return _c.postJson('/api/service', {
      'name': name,
      'price': price,
      'serviceTypeId': serviceTypeId,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (hourlyRate != null) 'hourlyRate': hourlyRate,
    });
  }

  /// Update a service
  Future<Map<String, dynamic>> updateService({
    required String serviceId,
    String? name,
    double? price,
    String? serviceTypeId,
    String? description,
    String? status,
  }) async {
    return _c.putJson('/api/service/$serviceId', {
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (serviceTypeId != null) 'serviceTypeId': serviceTypeId,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
    });
  }

  /// Delete a service
  Future<void> deleteService(String serviceId) async {
    await _c.deleteJson('/api/service/$serviceId');
  }
}

