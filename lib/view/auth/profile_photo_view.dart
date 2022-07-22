/// Copyright, 2022, by the authors. All rights reserved.
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:inkistry/core/values/app_images.dart';
import '../../core/values/system_overlay.dart';
import '../../core/viewmodel/auth_viewmodel.dart';

/// ProfilePhotoView is the view that allows the user to upload a profile photo.
/// It is used in the [AuthView] class.
/// It is used to upload a profile photo.
class ProfilePhotoView extends GetWidget<AuthViewModel> {
  const ProfilePhotoView({Key? key}) : super(key: key);

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
              /// Call the uploadUserImage method in the [AuthViewModel] class.
              /// On back button press.
              onPressed: () => controller.uploadUserImage(),
              icon: const Icon(FontAwesomeIcons.angleLeft),
            ),
            title: const Text(
              "Profile Photo",
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Profile photo upload message.
                    Text(
                        "Choose a high-quality photo for your avatar. It will be displayed in public feed with your post.",
                        style: Theme.of(context).textTheme.bodyText2),

                    /// Profile photo pick button.
                    /// Contain dashed border.
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 15.h),
                              child: InkWell(
                                onTap: () => controller.pickGalleryImage(),
                                borderRadius: BorderRadius.circular(80.r),
                                child: DottedBorder(
                                  borderType: BorderType.Circle,
                                  radius: Radius.circular(70.r),
                                  padding: EdgeInsets.all(5.w),
                                  color: const Color(0xFF6A7C9F),
                                  dashPattern: const [6, 3],
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(75.w)),

                                      /// Getx observable image.
                                      child: Obx(() => Container(
                                            height: 150.w,
                                            width: 150.w,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(

                                                    /// if the user has not uploaded a profile photo,
                                                    /// display the default profile photo.
                                                    /// else, display the user's profile photo.
                                                    image: controller.imagePath
                                                                .value !=
                                                            ''
                                                        ? FileImage(File(
                                                                controller
                                                                    .imagePath
                                                                    .value))
                                                            as ImageProvider
                                                        : const AssetImage(
                                                            AppImages.profilePhotoPlaceHolder),
                                                    fit: BoxFit.cover)),
                                          ))),
                                ),
                              ),
                            ),
                          ),

                          /// Profile photo upload button text.
                          Text("Tap here to choose photo",
                              style: Theme.of(context).textTheme.bodyText2),
                        ],
                      ),
                    ),
                  ],
                ),

                /// Profile photo upload button.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: MaterialButton(
                      /// Call the uploadUserImage method in the [AuthViewModel] class.
                      onPressed: () => controller.uploadUserImage(),
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
                              "NEXT",
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
