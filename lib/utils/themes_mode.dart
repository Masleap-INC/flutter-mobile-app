import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemesMode {
  static bool? isDarkMode;

  void init(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          isDarkMode == true ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness:
          isDarkMode == true ? Brightness.light : Brightness.dark,
      statusBarColor: isDarkMode == true ? Colors.black : Colors.white,
      statusBarBrightness:
          isDarkMode == true ? Brightness.light : Brightness.dark,
      statusBarIconBrightness:
          isDarkMode == true ? Brightness.light : Brightness.dark,
    ));
  }
}
