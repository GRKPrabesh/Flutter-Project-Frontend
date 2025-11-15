import 'package:flutter/material.dart';
import 'package:securityservice/loginpage.dart';
import 'package:securityservice/signup.dart';
import 'package:securityservice/role_select.dart';
import 'package:securityservice/second_page.dart';
import 'package:securityservice/third_page.dart';
import 'package:securityservice/uploadServicePage.dart';
import 'package:securityservice/dashboard_user.dart';
import 'package:securityservice/dashboard_org.dart';

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

  static Map<String, WidgetBuilder> getAppRoutes() => {
        loginPageRoute: (context) => const LoginScreen(),
        signUpRoute: (context) => const SignupScreen(),
        roleSelectRoute: (context) => const RoleSelectPage(),
        secondPageRoute: (context) => SecondPage(
              submitLabel: 'REGISTER',
              onSubmit: () => Navigator.pushNamed(context, loginPageRoute),
            ),
        thirdPageRoute: (context) => const ThirdPage(),
        // Organization flow
        orgStep1Route: (context) => SecondPage(
              submitLabel: 'NEXT',
              onSubmit: () => Navigator.pushNamed(context, orgPanRoute),
            ),
        orgPanRoute: (context) => ThirdPage(
              submitLabel: 'NEXT',
              onSubmit: () => Navigator.pushNamed(context, orgServiceUploadRoute),
            ),
        orgServiceUploadRoute: (context) => const ServiceUploadPage(),
        userDashboardRoute: (context) => const UserDashboardPage(),
        orgDashboardRoute: (context) => const OrganizationDashboardPage(),
      };
}
