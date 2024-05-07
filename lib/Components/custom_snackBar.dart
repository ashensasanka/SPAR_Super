import 'package:flutter/material.dart';

void showCustomSnackBar(
    BuildContext context, {
      required String message,
      required Color backgroundColor,
      required Color textColor,
      required IconData icon,
    }) {
  final snackBar = SnackBar(
    backgroundColor: backgroundColor, // Customizable background color
    content: Row(
      children: [
        Icon(icon, color: textColor), // Customizable icon
        SizedBox(width: 8), // Space between icon and text
        Text(
          message, // Customizable message
          style: TextStyle(color: textColor, fontSize: 16), // Customizable text style
        ),
      ],
    ),
    duration: Duration(seconds: 5), // Custom duration
    behavior: SnackBarBehavior.floating, // Make it floating
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Custom shape
    margin: EdgeInsets.all(10), // Margin from the edges
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Custom padding
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
