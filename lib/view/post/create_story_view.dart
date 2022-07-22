import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_images.dart';
import 'package:video_player/video_player.dart';

import '../../core/values/app_colors.dart';
import '../../core/viewmodel/create_story_viewmodel.dart';
import '../../model/capture_type.dart';
import 'hashtag_view.dart';
import 'mention_people_view.dart';

class CreateStoryView extends StatelessWidget {
  final CreateStoryViewModel controller;

  const CreateStoryView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
        !Get.isDarkMode ? const Color(0xFFF6F7F8) : const Color(0xFF000000),
        systemNavigationBarIconBrightness:
        !Get.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async {
          Get.back();
          Get.delete<CreateStoryViewModel>();
          return true;
        },
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              leading: Container(
                margin: REdgeInsets.only(left: 10.w, top: 5.h, bottom: 5.h),
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        bottomLeft: Radius.circular(8.r))),
                child: IconButton(
                  onPressed: () {
                    Get.back();
                    Get.delete<CreateStoryViewModel>();
                  },
                  icon: const Icon(
                    FontAwesomeIcons.arrowLeft,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Container(
                  padding: REdgeInsets.fromLTRB(0.w, 9.5.h, 10.w, 9.5.h),
                  decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r))),
                  child: Text(
                    "New ${controller.postType.value.name.capitalize!}",
                    style:
                        Get.textTheme.titleLarge!.copyWith(color: Colors.white),
                  )),
              actions: [
                Padding(
                  padding: REdgeInsets.fromLTRB(0.w, 5.h, 10.w, 5.h),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0.0),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black45),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    child: Text(
                      'Post',
                      style: Get.textTheme.titleLarge!
                          .copyWith(color: Colors.white),
                    ),
                    onPressed: () => controller.onPostButtonClick(),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: <Widget>[
                if (controller.captureType.value.name == CaptureType.video.name)
                  _videoPlayerView(),
                if (controller.captureType.value.name == CaptureType.photo.name)
                  Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                          image: FileImage(File(controller.imageFile.value)),
                          fit: BoxFit.cover),
                    ),
                  ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      //padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.25),
                              Colors.black.withOpacity(0.35),
                              Colors.black.withOpacity(0.45),
                              Colors.black.withOpacity(0.55),
                            ],
                            stops: const [
                              0.0,
                              0.25,
                              0.5,
                              0.75,
                              1.0
                            ]),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: REdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            child: Obx(() => Text(
                                  controller.storyCaptions.value != null
                                      ? controller.storyCaptions.value!.trim()
                                      : '',
                                  style: TextStyle(
                                      fontSize: 14.sp, color: Colors.white),
                                )),
                          ),
                          _captionFieldWidget()
                        ],
                      ),
                    ))
              ],
            )),
      ),
    );
  }

  /// Video player view
  Widget _videoPlayerView() {

    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Obx(
          () => controller.isVideoControllerInitialized.value
              ? Stack(
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
                              controller.videoController!.pause().then((value) {
                                controller.isVideoPlaying(false);
                              });
                            } else {
                              controller.videoController!.play().then((value) {
                                controller.isVideoPlaying(true);
                              });
                            }
                          }),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: VideoProgressIndicator(controller.videoController!,
                          allowScrubbing: false),
                    )
                  ],
                )
              : const SizedBox.shrink(),
        ));
  }

  Widget _captionFieldWidget() {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Obx(() => Container(
          //       height: 48.h,
          //       width: 48.h,
          //       margin: const EdgeInsets.only(right: 15),
          //       decoration: BoxDecoration(
          //           color: colorButtonDisable,
          //           borderRadius: BorderRadius.circular(8.r),
          //           border: Border.all(color: Colors.black38, width: 2),
          //           image: DecorationImage(
          //               image: controller.currentUser.value != null
          //                   ? controller.currentUser.value!.imageUrl!.isNotEmpty
          //                       ? CachedNetworkImageProvider(
          //                           controller.currentUser.value!.imageUrl!,
          //                         ) as ImageProvider
          //                       : const AssetImage(AppImages.guestUserLogo)
          //                   : const AssetImage(AppImages.guestUserLogo),
          //               fit: BoxFit.cover)),
          //     )),
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
              decoration: InputDecoration(
                labelText: 'Caption',
                hintText: 'Add a caption...',
                //contentPadding: REdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                prefixIcon: Obx(() => Container(
                  //height: 48.h,
                  width: 48.h,
                  margin: const EdgeInsets.only(left: 8, right: 15),
                  decoration: BoxDecoration(
                      color: AppColors.disabledButtonColor,
                      borderRadius: BorderRadius.circular(10.r),
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
                ))
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
}
