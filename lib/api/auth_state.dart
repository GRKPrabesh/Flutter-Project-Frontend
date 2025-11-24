class AuthState {
  static String? token;
  static String? email;

  static void setAuth({String? newToken, String? newEmail}) {
    if (newToken != null) token = newToken;
    if (newEmail != null) email = newEmail;
  }

  static void clear() {
    token = null;
    email = null;
  }
}


