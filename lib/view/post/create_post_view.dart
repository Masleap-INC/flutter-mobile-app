import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_images.dart';
import 'package:inkistry/view/post/tag_people_view.dart';
import 'package:video_player/video_player.dart';

import '../../core/values/app_colors.dart';
import '../../core/values/system_overlay.dart';
import '../../core/viewmodel/create_post_viewmodel.dart';
import '../../model/capture_type.dart';
import '../../model/post_type.dart';
import '../../model/user_model.dart';
import '../widgets/bottom_sheets/app_bottom_sheets.dart';
import 'hashtag_view.dart';
import 'mention_people_view.dart';

class CreatePostView extends StatelessWidget {
  final CreatePostViewModel controller;

  const CreatePostView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: WillPopScope(
        onWillPop: () async {
          Get.delete<CreatePostViewModel>();
          Get.back();
          return true;
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              leading: IconButton(
                onPressed: () {
                  Get.delete<CreatePostViewModel>();
                  Get.back();
                },
                icon: const Icon(
                  FontAwesomeIcons.angleLeft,
                ),
              ),
              title: Text("New ${controller.postType.value.name.capitalize!}"),
              actions: [
                Padding(
                  padding: REdgeInsets.all(15),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0.0),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          AppColors.appColorBlue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                    ),
                    child: Text(
                      'Post',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: Colors.white),
                    ),
                    onPressed: () => controller.onPostButtonClick(),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Wrap(
                children: [
                  if (controller.postType.value.name == PostType.post.name &&
                      controller.captureType.value.name ==
                          CaptureType.photo.name)
                    _postImageListWidget(),
                  if (controller.postType.value.name == PostType.stencil.name &&
                      controller.captureType.value.name ==
                          CaptureType.photo.name)
                    _stencilImageView(),
                  if (controller.captureType.value.name ==
                      CaptureType.video.name)
                    _videoPlayerView(),
                  _mediaActionListWidget(),
                  _captionFieldWidget(),
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 15),
                    child: Divider(height: 2.h, thickness: 2.h),
                  ),
                  _tagPeopleViewWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// This function is used to display the post image list
  Widget _postImageListWidget() {
    return Obx(() => Container(
          height: 100.h,
          width: double.infinity,
          padding: REdgeInsets.only(left: 15, top: 15),
          child: controller.imageFileList.isNotEmpty
              ? ListView.builder(
                  itemCount: controller.imageFileList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: REdgeInsets.only(right: 15),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 101.w,
                            height: 95.h,
                            margin: REdgeInsets.only(top: 10, right: 10),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: FileImage(
                                    File(controller.imageFileList[index]),
                                  ),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                height: 30.r,
                                width: 30.r,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: AppColors.disabledButtonColor,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(15.r)),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15.r),
                                    splashColor:
                                        Colors.redAccent.withOpacity(0.5),
                                    child: const Icon(
                                      FontAwesomeIcons.times,
                                      color: AppColors.disabledButtonColor,
                                      size: 22,
                                    ),
                                    onTap: () {
                                      controller.imageFileList.removeAt(index);
                                    },
                                  ),
                                ),
                              )),
                        ],
                      ),
                    );
                  })
              : const Text("+ Click on camera or gallery button to add images."
                  "\n+ You can't share post without caption and an image."
                  "\n+ Please take a picture or pick image from the gallery."),
        ));
  }

  /// This function is used to show the stencil image
  Widget _stencilImageView() {
    return Container(
      width: double.infinity,
      height: 200.0,
      margin: REdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: FileImage(
              File(controller.imageFileList[0]),
            ),
            fit: BoxFit.cover),
        borderRadius: BorderRadius.all(Radius.circular(15.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  /// Stencils category selection button
  Widget _stencilCategorySelectorWidget(
      {EdgeInsets? margin =
          const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5)}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => AppBottomSheets.stencilCategorySheet(controller),
        child: Container(
          padding: REdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: margin,
          decoration: BoxDecoration(
              color: Get.theme.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.disabledButtonColor)),
          child: Row(
            children: [
              const Text(
                'Category:',
              ),
              Expanded(
                child: Obx(() => Text(
                      controller.stencilsCategory.value,
                      textAlign: TextAlign.end,
                    )),
              ),
              Padding(
                padding: REdgeInsets.only(left: 10),
                child: const FaIcon(
                  FontAwesomeIcons.caretDown,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Video player view
  Widget _videoPlayerView() {
    return Container(
        width: double.infinity,
        height: 200.0,
        margin: REdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(15.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Obx(
          () => controller.isVideoControllerInitialized.value
              ? ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15.r)),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            height: controller.videoController!.value.size.height,
                            width: controller.videoController!.value.size.width,
                            child: VideoPlayer(controller.videoController!),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: Colors.black45,
                        child: IconButton(
                            icon: Obx(() => Icon(controller.isVideoPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow)),
                            onPressed: () async {
                              if (controller.videoController!.value.isPlaying) {
                                controller.videoController!
                                    .pause()
                                    .then((value) {
                                  controller.isVideoPlaying(false);
                                });
                              } else {
                                controller.videoController!
                                    .play()
                                    .then((value) {
                                  controller.isVideoPlaying(true);
                                });
                              }
                            }),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VideoProgressIndicator(
                            controller.videoController!,
                            allowScrubbing: false),
                      )
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ));
  }

  Widget _mediaActionListWidget() {
    return Padding(
      padding: REdgeInsets.all(10),
      child: Row(
        children: [
          if (controller.captureType.value.name != CaptureType.video.name)
            _mediaActionButton(
              icon: const Icon(FontAwesomeIcons.camera),
              onTap: () => controller.takeCameraImage(),
            ),
          if (controller.captureType.value.name != CaptureType.video.name)
            _mediaActionButton(
              icon: const Icon(FontAwesomeIcons.solidImages),
              onTap: () => controller.pickGalleryImage(),
            ),
          if (controller.postType.value.name == PostType.stencil.name)
            _stencilCategorySelectorWidget(
                margin: controller.captureType.value.name ==
                        CaptureType.video.name
                    ? const EdgeInsets.symmetric(vertical: 7.5, horizontal: 5.0)
                    : null),
        ],
      ),
    );
  }

  Widget _mediaActionButton({required Icon icon, required VoidCallback onTap}) {
    return Container(
      height: 48.h,
      width: 48.h,
      margin: REdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          splashColor: Colors.white.withOpacity(0.5),
          child: icon,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _captionFieldWidget() {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Container(
                height: 60.h,
                width: 60.h,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    color: AppColors.disabledButtonColor,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.black38, width: 2),
                    image: DecorationImage(
                        image: controller.currentUser.value != null
                            ? controller.currentUser.value!.imageUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    controller.currentUser.value!.imageUrl!,
                                  ) as ImageProvider
                                : const AssetImage(AppImages.guestUserLogo)
                            : const AssetImage(AppImages.guestUserLogo),
                        fit: BoxFit.cover)),
              )),
          Expanded(
            child: TextField(
              autofocus: false,
              onChanged: (value) async {
                if (value.endsWith("#")) {
                  String result = await Get.to(() => const HashtagView());
                  controller.captionTextEditingController.text += result;
                } else if (value.endsWith("# ")) {
                  controller.captionTextEditingController.text =
                      value.replaceAll('# ', '');
                } else if (value.endsWith("@")) {
                  String result = await Get.to(() => MentionPeopleView(
                        currentUserId: controller.currentUser.value!.id!,
                      ));
                  controller.captionTextEditingController.text += result;
                } else if (value.endsWith("@ ")) {
                  controller.captionTextEditingController.text =
                      value.replaceAll('@ ', '');
                }
              },
              controller: controller.captionTextEditingController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Add a caption...',
              ),
              minLines: 1,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagPeopleViewWidget() {
    return Column(
      children: [
        Padding(
          padding: REdgeInsets.all(15),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.to(() => TagPeopleView(
                      currentUserId: controller.currentUser.value!.id!,
                    )),
                child: Text(
                  '+ Tag People',
                  style: Get.textTheme.bodyText2!
                      .copyWith(color: AppColors.appColorBlue),
                ),
              ),
              const Spacer(),
              Obx(() => Text(
                    '${controller.taggedPeopleList.length} persons',
                    style: Get.textTheme.bodyText2!
                        .copyWith(color: AppColors.disabledButtonColor),
                  )),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Obx(() => Wrap(
                spacing: 5,
                runSpacing: 5,
                alignment: WrapAlignment.start,
                children: controller.taggedPeopleList
                    .map((e) => peopleTagChip(e, () {
                          controller.taggedPeopleList
                              .removeWhere((element) => element.id == e.id);
                        }))
                    .toList(),
              )),
        )
      ],
    );
  }

  Widget peopleTagChip(UserModel taggedUser, VoidCallback onTap) {
    return Container(
      padding: REdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(Get.isDarkMode),
        borderRadius: BorderRadius.circular(23.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 30.r,
            width: 30.r,
            margin: REdgeInsets.only(right: 8),
            decoration: BoxDecoration(
                color: AppColors.disabledButtonColor,
                borderRadius: BorderRadius.circular(15.r),
                border:
                    Border.all(color: AppColors.disabledButtonColor, width: 2),
                image: DecorationImage(
                    image: taggedUser.imageUrl!.isNotEmpty
                        ? NetworkImage(taggedUser.imageUrl!)
                        : const AssetImage(AppImages.guestUserLogo)
                            as ImageProvider)),
          ),
          Text(
            taggedUser.name!,
          ),
          GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: REdgeInsets.only(left: 15),
                child: const Icon(
                  FontAwesomeIcons.times,
                  color: AppColors.disabledButtonColor,
                ),
              ))
        ],
      ),
    );
  }
}
