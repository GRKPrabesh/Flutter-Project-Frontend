import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'auth_state.dart';

/// Simple HTTP client wrapper for calling the Protego backend.
class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: q);

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final t = AuthState.token;
    if (t != null && t.isNotEmpty) headers['Authorization'] = 'Bearer $t';
    return headers;
  }

  Future<List<dynamic>> getJsonList(String path,
      {Map<String, String>? query}) async {
    final res = await _client.get(_u(path, query), headers: _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      return body is List ? body : (body['data'] as List? ?? []);
    }
    throw Exception('GET $path failed (${res.statusCode})');
  }

  Future<Map<String, dynamic>> getJson(String path,
      {Map<String, String>? query}) async {
    final res = await _client.get(_u(path, query), headers: _headers());
    
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // Include response body in error for better debugging
    String errorMsg = 'GET $path failed (${res.statusCode})';
    if (res.body.isNotEmpty) {
      try {
        final errorBody = jsonDecode(res.body) as Map<String, dynamic>?;
        errorMsg = errorBody?['message']?.toString() ?? errorMsg;
      } catch (_) {
        // If JSON decode fails, use status code message
      }
    }
    throw Exception(errorMsg);
  }

  Future<Map<String, dynamic>> postJson(
      String path, Map<String, dynamic> body) async {
    final res = await _client.post(
      _u(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // Include response body in error for better debugging
    String errorMsg = 'POST $path failed (${res.statusCode})';
    if (res.body.isNotEmpty) {
      try {
        final errorBody = jsonDecode(res.body) as Map<String, dynamic>?;
        errorMsg = errorBody?['message']?.toString() ?? errorMsg;
      } catch (_) {
        // If JSON decode fails, use status code message
      }
    }
    throw Exception(errorMsg);
  }

  /// POST returning raw status + decoded body map.
  Future<Map<String, dynamic>> postJsonResp(
      String path, Map<String, dynamic> body) async {
    final res = await _client.post(
      _u(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    Map<String, dynamic> decoded = {};
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        decoded = {};
      }
    }
    return {
      'status': res.statusCode,
      'body': decoded,
    };
  }

  Future<Map<String, dynamic>> putJson(
      String path, Map<String, dynamic> body) async {
    final res = await _client.put(
      _u(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // Include response body in error for better debugging
    String errorMsg = 'PUT $path failed (${res.statusCode})';
    if (res.body.isNotEmpty) {
      try {
        final errorBody = jsonDecode(res.body) as Map<String, dynamic>?;
        errorMsg = errorBody?['message']?.toString() ?? errorMsg;
      } catch (_) {
        // If JSON decode fails, use status code message
      }
    }
    throw Exception(errorMsg);
  }

  Future<void> deleteJson(String path) async {
    final res = await _client.delete(
      _u(path),
      headers: _headers(),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    }
    String errorMsg = 'DELETE $path failed (${res.statusCode})';
    if (res.body.isNotEmpty) {
      try {
        final errorBody = jsonDecode(res.body) as Map<String, dynamic>?;
        errorMsg = errorBody?['message']?.toString() ?? errorMsg;
      } catch (_) {
        // If JSON decode fails, use status code message
      }
    }
    throw Exception(errorMsg);
  }
}


