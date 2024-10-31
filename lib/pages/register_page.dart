import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trucker/components/my_loading_circle.dart';
import 'package:trucker/services/auth/auth_service.dart';
import 'package:trucker/services/database/database_service.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';

/*
REGISTER PAGE

on this page, a new user can fill out the form and create an account.
the data we wwant from the user is:

-name
-email
-password
-confirm password
---------------------------------------------------------------------

once the user successfully creates an account --> they will be redirected to homepage

also, if user already has an account they can go to login page from here

 */

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //access auth service
  final _auth = AuthService();
  final _db = DatabaseService();
  //text controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordwController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  //register button tapped
  void register() async {
    // password match - > create user
    if (passwordwController.text == confirmPasswordController.text) {
      // show loading circle
      showLoadingCircle(context);

      // attempt to register user
      try {
        await _auth.registerEmailPassword(
          emailController.text,
          passwordwController.text,
        );

        // finished loading
        if (mounted) hideLoadingCircle(context);

        // once registerd, create and save user profile in database
        await _db.saveUserInfoInFirebase(
          name: nameController.text,
          email: emailController.text,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'user');
        await prefs.setBool('isLoggedIn', true);
        if (mounted) Navigator.pushReplacementNamed(context, '/first-page');

        // everytime you add a new package, it's a good practice to kill the app and restart
      }
      // catch any errors
      catch (e) {
        // finished loading
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
    // password don't match -> show error
    else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Password don't match!"),
        ),
      );
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

                  //create an account message
                  Text(
                    "Let's create an account for you",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 25),
                  //name textfield
                  MyTextField(
                    controller: nameController,
                    hintText: "Name",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),
                  //email textfield
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  //password textfield
                  MyTextField(
                    controller: passwordwController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),

                  //confirm password textfield
                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    obscureText: true,
                  ),

                  const SizedBox(height: 25),

                  //sign up button
                  MyButton(
                    text: "Register",
                    onTap: register,
                  ),

                  const SizedBox(height: 50),

                  //already a member? login here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already a member?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),

                      //user can tap this to go to login page
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Login now",
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
