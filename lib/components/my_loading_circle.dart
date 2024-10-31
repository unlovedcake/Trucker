import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showLoadingCircle(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissing by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor:
            Colors.transparent, // Makes the dialog background transparent
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Lottie.network(
              'https://lottie.host/34b2c60c-6857-4f14-a604-e47209f7de13/aZfyMldA9V.json'), // Correct usage of Lottie.asset
        ),
      );
    },
  );
}

// To hide the loading circle
void hideLoadingCircle(BuildContext context) {
  Navigator.pop(context);
}
