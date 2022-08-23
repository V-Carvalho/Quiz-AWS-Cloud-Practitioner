import 'package:flutter/material.dart';
import 'package:awsquiz/src/helpers/Constants.dart';

class MySnackBar {
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 50,
        backgroundColor: myDarkBlueColor,
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'AWS',
            color: myWhiteColor,
            fontWeight: FontWeight.normal,
            fontSize: MediaQuery.of(context).size.height * 2 / 100
          )
        ),
        duration: const Duration(seconds: 1)
      )
    );
  }
}