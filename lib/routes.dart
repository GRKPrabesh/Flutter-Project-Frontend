import 'package:flutter/material.dart';
import 'package:securityservice/admin_dashboard.dart';
import 'package:securityservice/loginpage.dart';
import 'package:securityservice/role_select.dart';
import 'package:securityservice/second_page.dart';
import 'package:securityservice/third_page.dart';
import 'package:securityservice/uploadServicePage.dart';
import 'package:securityservice/dashboard_user.dart';
import 'package:securityservice/dashboard_org.dart';
import 'package:securityservice/my_bookings_page.dart';
import 'package:securityservice/profile_page.dart';
import 'package:securityservice/search_orgs_page.dart';
import 'package:securityservice/verify_otp.dart';
import 'package:securityservice/signup.dart';

class AppRoute {
  AppRoute._();

  static const String loginPageRoute = '/login';
  static const String signUpRoute = '/signup';
  static const String roleSelectRoute = '/role-select';
  static const String secondPageRoute = '/second';
  static const String thirdPageRoute = '/third';
  static const String orgStep1Route = '/org/step1';
  static const String orgPanRoute = '/org/pan';
  static const String orgServiceUploadRoute = '/org/upload';
  static const String userDashboardRoute = '/dashboard/user';
  static const String orgDashboardRoute = '/dashboard/org';
  static const String adminDashboardRoute = '/dashboard/admin';
  static const String searchOrgsRoute = '/search';
  static const String myBookingsRoute = '/bookings';
  static const String profileRoute = '/profile';
  static const String verifyOtpRoute = '/verify-otp';

  static Map<String, WidgetBuilder> getAppRoutes() => {
        loginPageRoute: (context) => const LoginScreen(),
        signUpRoute: (context) => const SignupScreen(),
        roleSelectRoute: (context) => const RoleSelectPage(),
        secondPageRoute: (context) => const SecondPage(),
        thirdPageRoute: (context) => const ThirdPage(),
        orgStep1Route: (context) => const SecondPage(),
        orgPanRoute: (context) => const ThirdPage(),
        orgServiceUploadRoute: (context) => const ServiceUploadPage(),
        userDashboardRoute: (context) => const UserDashboardPage(),
        orgDashboardRoute: (context) => const OrganizationDashboardPage(),
        adminDashboardRoute: (context) => const AdminDashboardPage(),
        searchOrgsRoute: (context) => Scaffold(appBar: AppBar(title: const Text('Search')), body: SearchOrgsPage()),
        myBookingsRoute: (context) => Scaffold(appBar: AppBar(title: const Text('My Bookings')), body: MyBookingsPage()),
        profileRoute: (context) => const ProfilePage(),
        verifyOtpRoute: (context) => const VerifyOtpPage(),
      };
}
