import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../core/values/app_colors.dart';

String? validateEmail(String value) {
  RegExp regex =
      RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
          r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
          r"{0,253}[a-zA-Z0-9])?)*$");

  if (value.isEmpty) {
    return 'Email invalid or not found';
  } else {
    if (!regex.hasMatch(value)) {
      return 'Enter valid email address';
    } else {
      return null;
    }
  }
}

String? validatePassword(String value) {
  // r'^
  //   (?=.*[A-Z])       // should contain at least one upper case
  //   (?=.*[a-z])       // should contain at least one lower case
  //   (?=.*?[0-9])      // should contain at least one digit
  //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
  //     .{8,}           // Must be at least 8 characters in length
  // $

  RegExp regex = RegExp(r"^.{8,}$");

  if (value.isEmpty) {
    return 'Password invalid';
  } else {
    if (!regex.hasMatch(value)) {
      return 'Password must be at least 8 characters in length';
    } else {
      return null;
    }
  }
}

void showMessage(String str) => Fluttertoast.showToast(
    msg: str,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1);

showLoaderDialog(BuildContext context) => showDialog(
    context: context,
    barrierColor: Colors.grey.withOpacity(0.3),
    builder: (_) => Center(
            child: Container(
          width: 100.0,
          height: 100.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ]),
          child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.appColorRed)),
        )));

