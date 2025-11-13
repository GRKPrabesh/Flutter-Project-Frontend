import 'package:flutter/material.dart'; // Must import Flutter material for context and screens
import 'package:securityservice/loginpage.dart'; // Assuming the file defines LoginScreen
import 'package:securityservice/signup.dart'; // Assuming the file defines SignupScreen


class AppRoute {
  AppRoute._();

  static const String loginPageRoute = '/login';
  static const String signUpRoute = '/signup';


  static Map<String, WidgetBuilder> getAppRoutes() => {
    // CRITICAL FIX: Use PascalCase for class names (e.g., LoginScreen)
    loginPageRoute: (context) => const LoginScreen(),
    signUpRoute: (context) => const SignupScreen(),

  };
}