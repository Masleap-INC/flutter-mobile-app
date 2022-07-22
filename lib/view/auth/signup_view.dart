/// Copyright, 2022, by the authors. All rights reserved.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/system_overlay.dart';
import 'package:inkistry/utils/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkistry/view/auth/signin_view.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_images.dart';
import '../../core/viewmodel/auth_viewmodel.dart';

/// Sign up view.
/// Sign up with name, email and password.
/// Must accept the terms and conditions and privacy policy.
class SignUpView extends GetWidget<AuthViewModel> {
  SignUpView({Key? key}) : super(key: key);

  /// Global key for the form.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      /// System overlay style for the sign in page.
      value: SystemOverlay.common,
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Loading the app logo.
                  Padding(
                    padding: REdgeInsets.all(60),
                    child: SvgPicture.asset(
                      AppImages.authSignUpViewLogo,
                      height: 100,
                    ),
                  ),

                  /// Form title.
                  SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Sign Up",
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
                          /// Name input.
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              hintText: 'Ishtian Revee',
                            ),
                            keyboardType: TextInputType.name,
                            obscureText: false,
                            initialValue: '',

                            /// Checking if the name is valid.
                            /// If not, return an error message.
                            /// Else, return null.
                            validator: (value) => value!.length >= 4
                                ? null
                                : "Name must be at least 4 characters in length",
                            onSaved: (value) {
                              controller.name = value;
                            },
                          ),

                          /// Space between the name input and the email input.
                          SizedBox(
                            height: 38.h,
                          ),

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

                  // Privacy policy and terms and conditions.
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.3,
                          origin: const Offset(40, 0),
                          child: Obx(() => Checkbox(
                                checkColor: Colors.white,
                                activeColor: const Color(0xFF6A7C9F),
                                value: controller.isPrivacyPolicyChecked.value,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                onChanged: (bool? value) =>
                                    controller.isPrivacyPolicyChecked(value!),
                              )),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: "By signing up, I accept all the",
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                                TextSpan(
                                  text: "Terms and Conditions",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(color: const Color(0xFF125BE4)),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                                TextSpan(
                                    text: " and ",
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(color: const Color(0xFF125BE4)),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        )
                      ],
                    ),
                  ),

                  /// Sign up button.
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: MaterialButton(
                      onPressed: () async {
                        /// Checking if the form is valid.
                        /// If valid, sign in with email and password.
                        /// Else, Do nothing.
                        if (controller.isPrivacyPolicyChecked.value) {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            controller.signUpWithEmailAndPassword();
                          }
                        } else {
                          Get.snackbar(
                            'Failed to login..',
                            'You have to accept the Terms and Conditions and Privacy Policy',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: Ink(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: AppColors.enabledButtonColor,
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.0),
                            )),
                        child: Container(
                            padding: EdgeInsets.all(15.h),
                            alignment: Alignment.center,
                            child: const Text("SIGN UP",
                                style: TextStyle(color: Colors.white))),
                      ),
                      splashColor: Colors.black12,
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),

                  /// Already have an account
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: "Already have an account? ",
                              style: Theme.of(context).textTheme.bodyText2),
                          TextSpan(
                            text: "Sign In",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                /// Navigate to the sign in page.
                                Get.off(SignInView());
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
}
