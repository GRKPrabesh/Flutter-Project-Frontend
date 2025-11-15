import 'dart:async';

class ServicesApi {
  // Simulate fetching service names from backend
  static Future<List<String>> fetchServiceNames() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      'Guard Patrol',
      'CCTV Monitoring',
      'Access Control',
      'Event Security',
      'Alarm Response',
    ];
  }
}
