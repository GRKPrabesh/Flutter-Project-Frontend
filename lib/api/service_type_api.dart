import 'client.dart';

/// Service Type API for managing service types
class ServiceTypeApi {
  final ApiClient _c;
  ServiceTypeApi({ApiClient? client}) : _c = client ?? ApiClient();

  /// Get all active service types
  Future<List<Map<String, dynamic>>> fetchServiceTypes() async {
    final list = await _c.getJsonList('/api/service-type');
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Create a new service type
  Future<Map<String, dynamic>> createServiceType({
    required String name,
    String? description,
  }) async {
    return _c.postJson('/api/service-type', {
      'name': name,
      if (description != null) 'description': description,
    });
  }
}

