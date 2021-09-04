import 'package:flutter/material.dart';

void showSnack(context, String msg, bool isError) {
  Color error = Colors.red.shade900.withOpacity(0.96);
  Color? success = Colors.green.shade800.withOpacity(0.98);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    // behavior: SnackBarBehavior.floating,
    backgroundColor: isError ? error : success,
    padding: EdgeInsets.symmetric(horizontal: 15),
    elevation: 10,
    duration: Duration(seconds: 2),
    content: Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.cloud_done,
          color: Colors.white,
          size: 16,
        ),
        Text(
          "    " + msg,
          style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter'),
        ),
      ],
    ),
  ));
}
