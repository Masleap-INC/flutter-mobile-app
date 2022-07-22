/// Copyright, 2022, by the authors. All rights reserved.

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'core/services/themes_service.dart';
import 'core/values/app_config.dart';
import 'core/values/app_images.dart';
import 'helper/binding.dart';
import 'utils/themes.dart';
import 'utils/themes_mode.dart';
import 'view/control_view.dart';

/// Main entry point of the application.
/// This is the first function that is called when the app is started.
/// It is responsible for initializing the app.
/// It is also responsible for initializing the [GetStorage] package.
/// It is also responsible for initializing the [Firebase] package.
/// It is also responsible for initializing the [AppImages] package.
/// It is also responsible for initializing the [ThemeService] package.
/// It is also responsible for initializing the [Binding] package.
/// It is also responsible for initializing the [ScreenUtil] package.
/// It is also responsible for initializing the [AppConfig] package.
/// It is also responsible for initializing the [ControlView] package.
/// It is also responsible for initializing the [Theme] package.
/// It is also responsible for initializing the [ThemeMode] package.


List<CameraDescription> camerasList = <CameraDescription>[];

void main() async {
  /// WidgetsFlutterBinding is the main entry point of the Flutter framework.
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the [Firebase] package.
  await Firebase.initializeApp();

  /// Initialize the [GetStorage] package.
  await GetStorage.init();

  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    camerasList = await availableCameras();
  } on CameraException catch (e) {
    if (e.description != null) {
      if (kDebugMode) {
        print('Error: ${e.code}\nError Message: ${e.description}');
      }
    } else {
      if (kDebugMode) {
        print('Error: ${e.code}');
      }
    }
  }

  /// Run the flutter app.
  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    /// Initialize the [ThemeService] package.
    ThemesMode().init(context);

    /// Precache the background image.
    precacheImage(const AssetImage(AppImages.welcomeBackground), context);

    /// OrientationBuilder is used to determine the orientation of the device.
    return OrientationBuilder(
      /// ScreenUtil is used to determine the screen size of the device.
      builder: (context, orientation) => ScreenUtilInit(
        designSize: orientation == Orientation.portrait
            ? const Size(375, 812)
            : const Size(812, 375),

        /// Return the [GetMaterialApp] widget.
        builder: (BuildContext context, child) => GetMaterialApp(
          /// Initialize the [Binding] package.
          initialBinding: Binding(),

          /// Initialize the light app theme.
          theme: Themes.light,

          /// Initialize the dark app theme.
          darkTheme: Themes.dark,

          /// Get the current app theme.
          themeMode: ThemesService().theme(),

          /// Set the app home view.
          home: const ControlView(),
          // home: MainPage(),

          /// Disable the debug banner.
          debugShowCheckedModeBanner: false,

          /// Set the app title.
          title: AppConfig.appName,
        ),
      ),
    );
  }
}
