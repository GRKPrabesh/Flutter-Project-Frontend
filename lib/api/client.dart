import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _u(String path, [Map<String, String>? q]) => Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: q);

  Future<List<dynamic>> getJsonList(String path, {Map<String, String>? query}) async {
    final res = await _client.get(_u(path, query), headers: {'Content-Type': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      return body is List ? body : (body['data'] as List? ?? []);
    }
    throw Exception('GET $path failed (${res.statusCode})');
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, String>? query}) async {
    final res = await _client.get(_u(path, query), headers: {'Content-Type': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('GET $path failed (${res.statusCode})');
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final res = await _client.post(_u(path), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('POST $path failed (${res.statusCode})');
  }
}
