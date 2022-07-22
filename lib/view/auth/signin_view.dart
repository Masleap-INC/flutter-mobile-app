/// Copyright, 2022, by the authors. All rights reserved.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/system_overlay.dart';
import 'package:inkistry/utils/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkistry/view/auth/forgot_password_view.dart';
import 'package:inkistry/view/auth/signup_view.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_images.dart';
import '../../core/viewmodel/auth_viewmodel.dart';

/// Sign in view.
/// Sign in with email and password.
/// Sign in with Google.
/// Sign in with Facebook.
/// Sign in with Apple. [Upcoming feature]
class SignInView extends GetWidget<AuthViewModel> {
  SignInView({Key? key}) : super(key: key);

  /// Global key for the form.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    context.theme;
    /// System overlay style for the sign in page.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: REdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Loading the app logo.
                  Padding(
                    padding: REdgeInsets.all(60),
                    child: SvgPicture.asset(
                      AppImages.authSignInViewLogo,
                      height: 100,
                    ),
                  ),

                  /// Form title.
                  SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Sign In",
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.titleLarge,
                      )),

                  /// Sign in form.
                  Padding(
                    padding: REdgeInsets.symmetric(vertical: 15),
                    child: Form(
                      /// form key.
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          /// Email input.
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'example@gmail.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            obscureText: false,
                            initialValue: '',
                            validator: (value) {
                              /// Checking if the email is valid.
                              /// If not, return an error message.
                              /// Else, return null.
                              return validateEmail(value!);
                            },
                            onSaved: (value) {
                              controller.email = value;
                            },
                          ),

                          /// Space between the email input and the password input.
                          SizedBox(
                            height: 38.h,
                          ),

                          /// Password input.
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: '***********',
                                hintStyle: TextStyle()),
                            keyboardType: TextInputType.emailAddress,
                            initialValue: '',
                            obscureText: true,

                            /// Validating the password.
                            /// If not, return an error message.
                            /// Else, return null.
                            validator: (value) => validatePassword(value!),
                            onSaved: (value) {
                              controller.password = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Forgot password button.
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => Get.to(() => ForgotPasswordView()),
                        child: Text(
                          "Forgot password?",
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ),
                  ),

                  /// Sign in button.
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: MaterialButton(
                      onPressed: () async {
                        /// Checking if the form is valid.
                        /// If valid, sign in with email and password.
                        /// Else, Do nothing.
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          controller.signInWithEmailAndPassword();
                        }
                      },
                      child: Ink(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: AppColors.appColorRed,
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.0),
                            )),
                        child: Container(
                            padding: EdgeInsets.all(15.h),
                            alignment: Alignment.center,
                            child: const Text("SIGN IN",
                                style: TextStyle(color: Colors.white))),
                      ),
                      splashColor: Colors.black12,
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                  Text(
                    "or, continue with",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),

                  /// Social media buttons.
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: Row(
                      children: [
                        /// Google button.
                        customSocialButton(
                          icon: SvgPicture.asset(AppImages.authGoogleIcon),
                          onPressed: () async {
                            /// Sign in with Google.
                            controller.signInWithGoogleAccount();
                          },
                        ),

                        /// Space between the google button and the facebook button.
                        SizedBox(
                          width: 3.w,
                        ),

                        /// Facebook button.
                        customSocialButton(
                            icon: SvgPicture.asset(AppImages.authFacebookIcon),
                            onPressed: () async {
                              /// Sign in with Facebook.
                              controller.signInWithFacebookAccount();
                            }),

                        /// Space between the facebook button and the apple button.
                        SizedBox(
                          width: 3.w,
                        ),

                        /// Apple button.
                        customSocialButton(
                            icon: SvgPicture.asset(
                              AppImages.authAppleIcon,
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : null,
                            ),
                            onPressed: () {
                              showMessage("Coming soon...");

                              /// Sign in with Apple.
                              /// controller.signInWithAppleAccount();
                            }),
                      ],
                    ),
                  ),

                  /// Don't have an account? Sign up button.
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          TextSpan(
                            text: "Sign Up",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                /// Navigate to the sign up page.
                                Get.off(SignUpView());
                              },
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Custom social media button.
  Widget customSocialButton(
      {required Widget icon, required VoidCallback onPressed}) {
    return Expanded(
      child: MaterialButton(
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color(0xFFB1BCD0),
              )),
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
              alignment: Alignment.center,
              child: icon),
        ),
        splashColor: Colors.black12,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
