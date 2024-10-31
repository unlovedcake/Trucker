import 'package:flutter/material.dart';
import 'package:trucker/pages/login_page.dart';
import 'package:trucker/pages/register_page.dart';
/*

LOG IN OR REGISTER PAGE

this determines whether to show login page or register page.

 */

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initially, show login page
  bool showLoginPage = true;

  //toggle between login & register pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

//Build UI
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}
