/// Copyright, 2022, by the authors. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkistry/core/values/app_colors.dart';
import '../../../utils/extension.dart';
import '../../core/values/system_overlay.dart';
import '../../core/viewmodel/auth_viewmodel.dart';

/// ForgotPasswordView is the view that allows the user to reset their password.
/// It is used in the [AuthView] class.
/// It is used to reset the password.
class ForgotPasswordView extends GetWidget<AuthViewModel> {
  ForgotPasswordView({Key? key}) : super(key: key);

  /// Global form key.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    context.theme;
    /// System overlay style for the sign in page.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(FontAwesomeIcons.angleLeft),
            ),
            title: const Text("Forgot Password"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Forgot password message.
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                          "Enter the Email address associated with your account. We will email a link to reset your password.",
                          style: Theme.of(context).textTheme.bodyText2),
                    ),

                    /// Space between the forgot password message and the form.
                    SizedBox(
                      height: 15.h,
                    ),

                    /// Forgot password form.
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
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
                        ],
                      ),
                    ),
                  ],
                ),

                /// Forgot password button.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: MaterialButton(
                      onPressed: () async {
                        /// Checking if the form is valid.
                        /// If valid, sign in with email and password.
                        /// Else, Do nothing.
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          controller.sendPasswordResetLink();
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
                            padding: REdgeInsets.all(15),
                            alignment: Alignment.center,
                            child: Text(
                              "SEND",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: Colors.white),
                            )),
                      ),
                      splashColor: Colors.black12,
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
