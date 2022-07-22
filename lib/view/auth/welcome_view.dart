/// Copyright, 2022, by the authors. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkistry/core/values/system_overlay.dart';
import 'package:inkistry/view/auth/signin_view.dart';
import 'package:inkistry/view/auth/signup_view.dart';
import '../../core/services/location_service.dart';
import '../../core/values/app_images.dart';

/// The first view that is displayed when the app is started for the first time.
class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    /// Loading the precached background image.
    ImageProvider welcomeBackground =
        const AssetImage(AppImages.welcomeBackground);

    /// Checking the location permission.
    checkLocationPermission();

    /// The system overlay style for the welcome page.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.welcome,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,

            /// Loading the precached background image.
            image: DecorationImage(
              fit: BoxFit.fill,
              image: welcomeBackground,
            ),
          ),
          height: double.infinity,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  /// Loading the app logo.
                  Padding(
                    padding: REdgeInsets.all(60),
                    child: SvgPicture.asset(
                      AppImages.welcomeLogo,
                      height: 100,
                    ),
                  ),

                  /// Adding space between the logo and the buttons.
                  const Spacer(),

                  /// Loading the sign in button.
                  customWelcomeButton(
                    title: 'SIGN IN',
                    onTap: () => Get.off(SignInView()),
                  ),

                  /// Adding space between the buttons.
                  SizedBox(height: 15.h),

                  /// Loading the sign up button.
                  customWelcomeButton(
                    title: 'SIGN UP',
                    onTap: () => Get.off(SignUpView()),
                  ),
                  /// Adding space at the bottom of the page.
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Creating a custom welcome button.
  Widget customWelcomeButton(
      {required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MaterialButton(
        onPressed: onTap,
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.white)),
          child: Container(
              padding: EdgeInsets.all(20.h),
              alignment: Alignment.center,
              child: Text(title, style: const TextStyle(color: Colors.white))),
        ),
        splashColor: Colors.black12,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
  }
}
