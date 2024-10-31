import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trucker/components/my_drawer_tile.dart';
import 'package:trucker/components/navigate.dart';
import 'package:trucker/pages/profile_page.dart';
import 'package:trucker/services/auth/auth_service.dart';
import 'package:trucker/services/auth/login_or_register.dart';

import '../pages/settings_page.dart';

/*

DRAWER

This is a menu drawer which is usually access on the left side of the app bar

--------------------------------------------------------------------------------

Contains 4 menu options

- Home
- Profile
- Search
- Settings
- Logout


 */

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  // access auth service
  final _auth = AuthService();

  void logout(context) async {
    try {
      await _auth.logout();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', '');
      await prefs.setBool('isLoggedIn', false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
        (Route<dynamic> route) => false, // Removes all previous routes
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // Drawer
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // App logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              // Divider line
              Divider(color: Theme.of(context).colorScheme.secondary),

              const SizedBox(height: 10),

              // Home list tile
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: () {
                  // Pop since we are already at home
                  Navigator.pop(context);
                },
              ),

              // Profile list tile
              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: () {
                  // pop menu drawer
                  Navigator.pop(context);

                  // go to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(uid: _auth.getCurrentUid()),
                    ),
                  );
                },
              ),

              // Setting list tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {
                  //pop menu drawer
                  Navigator.pop(context);

                  //go to settings page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Logout list tile
              MyDrawerTile(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: () {
                  logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
