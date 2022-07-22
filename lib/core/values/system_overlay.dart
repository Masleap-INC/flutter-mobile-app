/// Copyright, 2022, by the authors. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// App SystemUiOverlayStyle.
/// This class is used to define the app SystemUiOverlayStyle.
abstract class SystemOverlay {
  static SystemUiOverlayStyle get welcome =>
      SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.black, systemNavigationBarColor: Colors.black);

  static SystemUiOverlayStyle get main => SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor:
            !Get.isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
        systemNavigationBarIconBrightness:
            !Get.isDarkMode ? Brightness.dark : Brightness.light,
        statusBarColor:
            !Get.isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
        statusBarBrightness:
            !Get.isDarkMode ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            !Get.isDarkMode ? Brightness.dark : Brightness.light,
      );

  static SystemUiOverlayStyle get common => SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor:
            !Get.isDarkMode ? const Color(0xFFF6F7F8) : const Color(0xFF000000),
        systemNavigationBarIconBrightness:
            !Get.isDarkMode ? Brightness.dark : Brightness.light,
        statusBarColor:
            !Get.isDarkMode ? const Color(0xFFF6F7F8) : const Color(0xFF000000),
        statusBarBrightness:
            !Get.isDarkMode ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            !Get.isDarkMode ? Brightness.dark : Brightness.light,
      );
}
