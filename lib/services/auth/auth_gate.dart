import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trucker/components/navigate.dart';
import 'package:trucker/helper/navigate_pages.dart';
import 'package:trucker/pages/home_page.dart';
import 'package:trucker/services/auth/login_or_register.dart';
/*

AUTH GATE

This is t check if the user is logged in or out

--------------------------------------------------------------------------------

if user is logged in -> go to homepage
if user is NOT logged in -> go to lgin or register page


 */

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    print('ROLE: $role');
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // if user is logged in
            if (snapshot.hasData) {
              return const FirstPage();
            }

            // if user is not logged in
            else {
              return const LoginOrRegister();
            }
          }),
    );
  }
}
