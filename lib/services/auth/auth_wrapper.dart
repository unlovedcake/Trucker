import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trucker/components/navigate.dart';
import 'package:trucker/pages/driver/driver_dashboard_page.dart';
import 'package:trucker/pages/home_page.dart';
import 'package:trucker/services/auth/login_or_register.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isLoggedIn = false;
  String? role;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('isLoggedIn') ?? false;

    String? fetchedRole = prefs.getString('role');

    setState(() {
      isLoggedIn = loggedIn && FirebaseAuth.instance.currentUser != null;
      role = fetchedRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const LoginOrRegister(); // Not logged in, show Login
    }

    // Check the user's role and navigate accordingly
    if (role == 'user') {
      return const FirstPage(); // User role, navigate to User home page
    } else if (role == 'driver') {
      return const DriverDashboardPage(); // Driver role, navigate to Driver home page
    }

    return Container(); // Fallback in case of unexpected role
  }
}
