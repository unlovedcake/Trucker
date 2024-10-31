import 'package:flutter/material.dart';

/*

INPUT ALERT BOX

This is an alert dialog box that has a textfield where the user can type in.
 We will use this things like editing bio, posting a new message, etc.

--------------------------------------------------------------------------------

To use this widget you need :

- Text controller (to access what the user type)
- Hint text 
- Function
- Text for button (Save)

 */

class MyInputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText,
  });

  @override
  Widget build(BuildContext context) {
    // Alert Dialog
    return AlertDialog(
      // Curve Corners
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),

      // Color
      backgroundColor: Theme.of(context).colorScheme.surface,

      // Textfield (User types here)
      content: TextField(
        controller: textController,

        // limit max characters
        maxLength: 140,
        maxLines: 3,

        decoration: InputDecoration(
          // border when textfield is unselected
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(25),
          ),

          // border when textfield is selected
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(25),
          ),

          // Hint text
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),

          // Color inside the textfield
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,

          // Counter style
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),

      // Buttons
      actions: [
        // cancel button
        TextButton(
          onPressed: () {
            // Close box
            Navigator.pop(context);

            // Clear controller
            textController.clear();
          },
          child: const Text("Cancel"),
        ),
        // yes button
        TextButton(
          onPressed: () {
            // Close the box
            Navigator.pop(context);

            // Execute function
            onPressed!();
            // Clear controller
            textController.clear();
          },
          child: Text(onPressedText),
        ),
      ],
    );
  }
}
