import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trucker/components/my_button.dart';
import 'package:trucker/components/my_loading_circle.dart';
import 'package:trucker/components/my_text_field.dart';
import 'package:trucker/components/navigate.dart';
import 'package:trucker/helper/navigate_pages.dart';
import 'package:trucker/pages/home_page.dart';
import 'package:trucker/services/auth/auth_gate.dart';
import 'package:trucker/services/auth/auth_service.dart';
import 'package:trucker/services/auth/auth_wrapper.dart';

import 'forgot_password.dart';

/*
LOGIN PAGE

on this page, an existing user can log in with their:

-email
-password
-------------------------------------------------------
 once the user successfully logs in, they will be redirected to the home page.

 if the user doesnt have an account yet, they can go to the register page from here.

 */

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // access auth service
  final _auth = AuthService();

  //  text controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  //  login method
  void login() async {
    // show loading circle
    showLoadingCircle(context);

    //attempt login
    try {
      // trying to login

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final userCredential = await _auth.loginEmailPasswod(
          emailController.text, pwController.text);

      // Fetch the user data from Firestore
      final userDoc = await _firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      // Check if user document exists and retrieve role
      if (userDoc.exists && userDoc['email'] == emailController.text) {
        // Save login state to shared_preferences

        String _role = userDoc['role'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', _role);
        await prefs.setBool('isLoggedIn', true);

        // Check the role and navigate to the appropriate page
        if (_role == 'user') {
          print('Navigate to user page.');
          if (mounted) Navigator.pushReplacementNamed(context, '/first-page');

          role = _role;
        } else {
          print('Navigate to driver page.');

          if (mounted)
            Navigator.pushReplacementNamed(context, '/driver-dashboard');
        }
      } else {
        print('User document does not exist or email does not match.');
        //finish loading
        if (mounted) hideLoadingCircle(context);
      }
    }

    // catch any errors
    catch (e) {
      //finish loading
      if (mounted) hideLoadingCircle(context);

      // let user know of the error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    //Scaffold
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //body
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  //Logo
                  Container(
                    height: 150,
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                      child: Image.asset('images/TruckerLogo.png'),
                    ),
                  ),

                  const SizedBox(height: 50),

                  //Welcome back message
                  Text(
                    "Welcome to Trucker!",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 25),

                  //email textfield
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  //password textfield
                  MyTextField(
                    controller: pwController,
                    hintText: "Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  //forgot password?
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPassword(),
                            ));
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  //sign in button
                  MyButton(
                    text: "Login",
                    onTap: login,
                  ),

                  const SizedBox(height: 50),

                  //not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),

                      //user can tap this to go to register page
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Register now",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
