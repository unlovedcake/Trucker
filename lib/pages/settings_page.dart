import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trucker/components/my_settings_tile.dart';
import 'package:trucker/themes/theme_provider.dart';

import '../helper/navigate_pages.dart';

/*

SETTINGS PAGE

-DARK MODE
-BLOCKED USERS
- ACCOUNT SETTINGS

 */

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    //SCAFFOLD
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //Appbar
      appBar: AppBar(
        title: const Text("S E T T I N G S"),
        centerTitle: true,
        foregroundColor: Color(0xFF6D9886),
      ),

      //body
      body: Column(
        children: [
          //dark mode tile
          MySettingsTile(
            title: "Dark Mode",
            action: CupertinoSwitch(
              onChanged: (value) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(),
              value:
                  Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
            ),
          ),

          //block users tile
          MySettingsTile(
            title: "Blocked Users",
            action: IconButton(
              onPressed: () => goBlockedUsersPage(context),
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          //account settings tile
          MySettingsTile(
            title: "Account Settings",
            action: IconButton(
              onPressed: () => goAccountSettingsPage(context),
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
