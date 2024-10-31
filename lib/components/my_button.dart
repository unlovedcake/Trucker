import 'package:flutter/material.dart';

/*
BUTTON 

a simple button
--------------------------------------

to use this widget, u need:
- text
- function (on tap)

 */

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  //Build UI
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        //padding inside
        padding: const EdgeInsets.all(25),

        decoration: BoxDecoration(
          //color of the button
          color: Color(0xFF6D9886),

          //curved corners
          borderRadius: BorderRadius.circular(12),
        ),

        //text
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
