import 'package:flutter/material.dart';

/*

USER BIO BOX

This is a simple box with text inside. We will use this for the user bio on their profile pages.

To use this widget, you just need :

- text

 */
class MyBioBox extends StatelessWidget {
  final String text;
  const MyBioBox({
    super.key,
    required this.text,
  });

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // Container
    return Container(
      //padding outside
      margin: const EdgeInsets.symmetric(horizontal: 25),

      //padding inside
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        // color
        color: Theme.of(context).colorScheme.secondary,

        // Curver corners
        borderRadius: BorderRadius.circular(8),
      ),

      child: Text(
        text.isNotEmpty ? text : "Empty Bio",
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
    );
  }
}
