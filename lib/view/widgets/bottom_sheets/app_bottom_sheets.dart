import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:inkistry/core/viewmodel/camera_viewmodel.dart';
import 'package:inkistry/core/viewmodel/create_post_viewmodel.dart';
import 'package:inkistry/core/viewmodel/post_card_viewmodel.dart';
import 'package:inkistry/core/viewmodel/profile_viewmodel.dart';
import 'package:inkistry/model/capture_type.dart';

import '../../../core/viewmodel/create_story_viewmodel.dart';
import '../../../model/post_model.dart';
import '../../../model/post_type.dart';
import '../../camera/camera_view.dart';
import '../../post/create_post_view.dart';
import '../../post/create_story_view.dart';
import '../custom_icon_text_button_widget.dart';
import 'post_type_widget.dart';

abstract class AppBottomSheets {
  /// Media choosing bottom sheet
  /// Select post type
  /// Pick photos or videos from the gallery or using camera
  static void chooseMediaSheet() {
    /// take A photo
    _takePhoto() async {
      bool test = Get.isRegistered<CameraViewModel>();
      if(test) {
        Get.find<CameraViewModel>().initCamera();
      }else{
        Get.put(CameraViewModel());
      }

      PostType postType = Get.find<PostTypeController>().postType.value;
      CaptureType captureType = CaptureType.photo;

      var result = await Get.to(() => CameraView(
            postType: postType,
            captureType: captureType,
          ));

      if (result != null) {
        if (postType == PostType.story) {
          Get.off(() => CreateStoryView(
              controller: Get.put(CreateStoryViewModel(
                  postType: postType,
                  captureType: captureType,
                  filePath: result))));
        } else {
          Get.off(() => CreatePostView(
              controller: Get.put(CreatePostViewModel(
                  postType: postType,
                  captureType: captureType,
                  filePath: result))));
        }
      }
    }

    /// pick A photo
    _pickPhoto() async {
      PostType postType = Get.find<PostTypeController>().postType.value;
      CaptureType captureType = CaptureType.photo;

      final _pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (_pickedFile != null) {
        if (postType == PostType.story) {
          Get.off(() => CreateStoryView(
              controller: Get.put(CreateStoryViewModel(
                  postType: postType,
                  captureType: captureType,
                  filePath: _pickedFile.path))));
        } else {
          Get.off(() => CreatePostView(
              controller: Get.put(CreatePostViewModel(
                  postType: postType,
                  captureType: captureType,
                  filePath: _pickedFile.path))));
        }
      }
    }

    /// take A video
    _takeVideo() async {
      Get.find<CameraViewModel>().initCamera();

      PostType postType = Get.find<PostTypeController>().postType.value;
      CaptureType captureType = CaptureType.video;

      var result = await Get.to(() => CameraView(
            postType: postType,
            captureType: captureType,
          ));

      if (result != null) {
        if (postType == PostType.story) {
          Get.off(() => CreateStoryView(
              controller: Get.put(CreateStoryViewModel(
                  postType: postType,
                  captureType: captureType,
                  filePath: result))));
        } else {
          Get.off(() => CreatePostView(
              controller: Get.put(CreatePostViewModel(
                  postType: postType,
                  captureType: captureType,
                  filePath: result))));
        }
      }
    }

    showModalBottomSheet(
        barrierColor: Colors.grey.withOpacity(0.2),
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.r),
            topLeft: Radius.circular(15.r),
          ),
        ),
        context: Get.context!,
        builder: (builder) {
          return Container(
            padding: REdgeInsets.fromLTRB(15, 0, 15, 5),
            decoration: BoxDecoration(
              color: Get.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.r),
                topLeft: Radius.circular(15.r),
              ),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: REdgeInsets.only(top: 10, bottom: 10),
                    child: SizedBox(
                      width: 30.w,
                      child: Divider(
                        height: 2.5.h,
                        thickness: 3.h,
                        color: AppColors.disabledButtonColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: REdgeInsets.only(bottom: 10.h),
                  child: Row(
                    children: [
                      Text(
                        "Choose Media",
                        style: Get.theme.textTheme.bodyText2,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          "Cancel",
                          style: Get.theme.primaryTextTheme.bodyText2,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconTextButtonWidget(
                    iconData: FontAwesomeIcons.camera,
                    text: "Take a Photo",
                    onPressed: () => _takePhoto()),
                CustomIconTextButtonWidget(
                    iconData: FontAwesomeIcons.solidImages,
                    text: "Choose From Gallery",
                    onPressed: () => _pickPhoto()),
                CustomIconTextButtonWidget(
                    iconData: FontAwesomeIcons.video,
                    text: "Take a Video",
                    onPressed: () => _takeVideo()),
                const PostTypeWidget(),
              ],
            ),
          );
        });
  }

  /// Stencils categories bottom sheet
  /// Select the stencil category from the category list
  static void stencilCategorySheet(dynamic controller) {
    showModalBottomSheet(
        barrierColor: Colors.grey.withOpacity(0.2),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        context: Get.context!,
        builder: (builder) {
          return Container(
            padding: REdgeInsets.fromLTRB(15, 0, 15, 5),
            decoration: BoxDecoration(
              color: Get.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.r),
                topLeft: Radius.circular(15.r),
              ),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: REdgeInsets.only(top: 10, bottom: 10),
                    child: SizedBox(
                      width: 30.w,
                      child: Divider(
                        height: 2.5.h,
                        thickness: 3.h,
                        color: AppColors.disabledButtonColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: REdgeInsets.only(bottom: 10.h),
                  child: Row(
                    children: [
                      Text(
                        "Select Category",
                        style: Get.theme.textTheme.bodyText2,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.focusScope!.unfocus();
                        },
                        child: Text(
                          "Cancel",
                          style: Get.theme.primaryTextTheme.bodyText2,
                        ),
                      ),
                    ],
                  ),
                ),
                for (var category in PostModel.stencilCatList)
                  Container(
                    padding: REdgeInsets.symmetric(vertical: 5.h),
                    height: 60.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {

                        controller.stencilsCategory.value =
                            category;
                        Get.back();
                        Get.focusScope!.unfocus();


                      },
                      child: Text(
                        category,
                        style: Get.theme.textTheme.titleMedium,
                      ),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0.0),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  )
              ],
            ),
          );
        });
  }

  /// Post card action bottom sheet
  /// Edit, Delete, Hide, Share, Save, Archive, CopyLink actions are allowed
  static void postCardActionSheet({required String controllerTag}) {
    showModalBottomSheet(
        barrierColor: Colors.grey.withOpacity(0.2),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        context: Get.context!,
        builder: (builder) {
          return Container(
            padding: REdgeInsets.fromLTRB(15, 0, 15, 5),
            decoration: BoxDecoration(
              color: Get.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.r),
                topLeft: Radius.circular(15.r),
              ),
            ),
            child: GetBuilder<PostCardViewModel>(
                init: Get.find<PostCardViewModel>(tag: controllerTag),
                builder: (controller) {
                  return Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      /// Sheets top bar
                      Center(
                        child: Padding(
                          padding: REdgeInsets.only(top: 10, bottom: 10),
                          child: SizedBox(
                            width: 30.w,
                            child: Divider(
                              height: 2.5.h,
                              thickness: 3.h,
                              color: AppColors.disabledButtonColor,
                            ),
                          ),
                        ),
                      ),

                      /// Sheets Header
                      Padding(
                        padding: REdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Text(
                              "Menu",
                              style: Get.theme.textTheme.bodyText2,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Get.back();
                                Get.focusScope!.unfocus();
                              },
                              child: Text(
                                "Cancel",
                                style: Get.theme.primaryTextTheme.bodyText2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Share Button
                      CustomIconTextButtonWidget(
                          iconData: FontAwesomeIcons.share,
                          text: "Share with friends",
                          onPressed: () => controller.sharePostWithFriend()),
                      CustomIconTextButtonWidget(
                          iconData: FontAwesomeIcons.link,
                          text: "Copy link",
                          onPressed: () => controller.copyPostLink()),

                      /// Only current user can see
                      if (controller.currentUser.value.id! ==
                          controller.post.value.authorId)
                        CustomIconTextButtonWidget(
                            iconData: FontAwesomeIcons.marker,
                            text: "Edit post",
                            onPressed: () => controller.navigateToEditPostPage()),

                      /// Only current user can see
                      if (controller.currentUser.value.id! ==
                          controller.post.value.authorId)
                        CustomIconTextButtonWidget(
                            iconData: FontAwesomeIcons.trashAlt,
                            text: "Move to trash",
                            onPressed: () => controller.moveToTrash()),
                      CustomIconTextButtonWidget(
                          iconData: FontAwesomeIcons.eyeSlash,
                          text: "Hide post from feed",
                          onPressed: () => controller.hidePost()),

                      /// Only current user can see
                      if (controller.currentUser.value.id! ==
                          controller.post.value.authorId)
                        CustomIconTextButtonWidget(
                            iconData: FontAwesomeIcons.archive,
                            text: "Move to archive",
                            onPressed: () => controller.moveToArchive()),
                      CustomIconTextButtonWidget(
                          iconData: FontAwesomeIcons.arrowDown,
                          text: "Save inkistry photo",
                          onPressed: () => controller.saveInkistryPhoto()),
                    ],
                  );
                }),
          );
        });
  }

  /// Current user menu sheet
  /// Settings, activity, bookmark post, archive post , deleted post, hidden post.
  static void userMenuSheet(String controllerTag) {
    showModalBottomSheet(
        barrierColor: Colors.grey.withOpacity(0.2),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        context: Get.context!,
        builder: (builder) {
          return Container(
            padding: REdgeInsets.fromLTRB(15, 0, 15, 5),
            decoration: BoxDecoration(
              color: Get.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.r),
                topLeft: Radius.circular(15.r),
              ),
            ),
            child: GetBuilder<ProfileViewModel>(
              init: Get.find<ProfileViewModel>(tag: controllerTag),
              builder: (controller) {

                bool isCurrentUser = controller.remoteUser.value!.id! == controller.localUser.value!.id!;


                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    /// Sheets top bar
                    Center(
                      child: Padding(
                        padding: REdgeInsets.only(top: 10, bottom: 10),
                        child: SizedBox(
                          width: 30.w,
                          child: Divider(
                            height: 2.5.h,
                            thickness: 3.h,
                            color: AppColors.disabledButtonColor,
                          ),
                        ),
                      ),
                    ),

                    /// Sheets Header
                    Padding(
                      padding: REdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Text(
                            "Menu",
                            style: Get.theme.textTheme.bodyText2,
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              Get.focusScope!.unfocus();
                            },
                            child: Text(
                              "Cancel",
                              style: Get.theme.primaryTextTheme.bodyText2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if(isCurrentUser)
                    CustomIconTextButtonWidget(
                        iconData: FontAwesomeIcons.cog,
                        text: "Settings",
                        onPressed: () => controller
                            .navigateToSettingsPostPage()),
                    CustomIconTextButtonWidget(
                        iconData: FontAwesomeIcons.link,
                        text: "Copy profile link",
                        onPressed: () =>
                            controller.copyProfileLink()),
                    // CustomIconTextButtonWidget(
                    //     iconData: FontAwesomeIcons.history,
                    //     text: "Activity",
                    //     onPressed: ()=> controller.navigateToActivityPage()
                    // ),
                    if(!isCurrentUser)
                      CustomIconTextButtonWidget(
                          iconData: FontAwesomeIcons.solidStar,
                          text: "Rate this artist",
                          onPressed: () => controller
                              .navigateToArtistsRatingPage()),
                    if(isCurrentUser)
                    CustomIconTextButtonWidget(
                        iconData: FontAwesomeIcons.solidBookmark,
                        text: "Saved post",
                        onPressed: () =>
                            controller.navigateToSavedPostPage()),
                    if(isCurrentUser)
                    CustomIconTextButtonWidget(
                        iconData: FontAwesomeIcons.archive,
                        text: "Archived post",
                        onPressed: () => controller
                            .navigateToArchivedPostPage()),
                    if(isCurrentUser)
                    CustomIconTextButtonWidget(
                        iconData: FontAwesomeIcons.solidEyeSlash,
                        text: "Hidden Post",
                        onPressed: () => controller
                            .navigateToHiddenPostPage()),
                    if(isCurrentUser)
                      CustomIconTextButtonWidget(
                        iconData: FontAwesomeIcons.trash,
                        text: "Deleted Post",
                        onPressed: () => controller
                            .navigateToDeletedPostPage()),
                  ],
                );
              }
            ),
          );
        });
  }
}
