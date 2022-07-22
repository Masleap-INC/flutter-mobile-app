import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../values/app_constants.dart';

class ThemesService {
  final _box = GetStorage();
  final _key = 'Theme';

  ThemeMode theme() {
    String? theme = getTheme();

    if(theme == AppConstants.light) {
      setTheme(AppConstants.light);
      return ThemeMode.light;
    } else if(theme == AppConstants.dark) {
      setTheme(AppConstants.dark);
      return ThemeMode.dark;
    }

    return ThemeMode.system;
  }

  void setTheme(String value) async{
    await _box.write(_key, value);

    ThemeMode theme;

    if(value == AppConstants.light) {
      theme = ThemeMode.light;
    } else if(value == AppConstants.dark) {
      theme = ThemeMode.dark;
    }else{
      theme = ThemeMode.system;
    }

    Get.changeThemeMode(theme);
  }

  String? getTheme() {
    return _box.read(_key) ?? AppConstants.systemDefault;
  }

}

