import 'package:flutter/material.dart';

/*

SETTINGS LIST TILE

This is a simple tile for each item in the settings page
-------------------------------------------------------------------

to use this widget, u need:
-title (eg. "dark mode")
-action (eg. toggleTheme() )

 */

class MySettingsTile extends StatelessWidget {
  final String title;
  final Widget action;

  const MySettingsTile({super.key, required this.title, required this.action});

// Build UI
  @override
  Widget build(BuildContext context) {
    //Container
    return Container(
      decoration: BoxDecoration(
        //color
        color: Theme.of(context).colorScheme.secondary,

        //curve corners
        borderRadius: BorderRadius.circular(12),
      ),

      //padding outside
      margin: const EdgeInsets.only(left: 25, right: 25, top: 10),

      //padding inside
      padding: const EdgeInsets.all(25),

      //Row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //title
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          //action
          action,
        ],
      ),
    );
  }
}
