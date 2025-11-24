import 'client.dart';
import 'auth_state.dart';

/// Auth-related API calls against the Protego backend.
class AuthApi {
  final ApiClient _c;
  AuthApi({ApiClient? client}) : _c = client ?? ApiClient();

  Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    final resp = await _c.postJsonResp('/api/auth/login', {
      'email': email,
      'password': password,
    });
    final body = (resp['body'] as Map<String, dynamic>? ?? {});
    final token = body['token'] as String?;
    if (token != null && token.isNotEmpty) {
      AuthState.setAuth(newToken: token, newEmail: email);
    } else {
      AuthState.setAuth(newEmail: email);
    }
    return resp;
  }

  Future<Map<String, dynamic>> verifyOtp(
      {required String email, required String otp}) async {
    final res = await _c.postJson('/api/auth/verify', {
      'email': email,
      'submittedOTP': otp,
    });
    final token = res['token'] as String?;
    if (token != null && token.isNotEmpty) {
      AuthState.setAuth(newToken: token, newEmail: email);
    }
    return res;
  }

  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    return _c.postJson('/api/auth/resend-otp', {
      'email': email,
    });
  }

  Future<Map<String, dynamic>> getProfile() async {
    return _c.getJson('/api/auth/profile');
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profilePic,
    String? companyName,
    String? address,
    String? orgProfilePic,
  }) async {
    return _c.putJson('/api/auth/profile', {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (profilePic != null) 'profilePic': profilePic,
      if (companyName != null) 'companyName': companyName,
      if (address != null) 'address': address,
      if (orgProfilePic != null) 'orgProfilePic': orgProfilePic,
    });
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _c.putJson('/api/auth/change-password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }
}


