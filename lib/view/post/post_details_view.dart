import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/viewmodel/post_card_viewmodel.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:readmore/readmore.dart';
import 'package:video_player/video_player.dart';

import '../../core/values/app_colors.dart';
import '../../model/capture_type.dart';

class PostDetailsView extends StatelessWidget {
  final String controllerTag;

  const PostDetailsView({Key? key, required this.controllerTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: WillPopScope(
        onWillPop: () async {
          Get.find<PostCardViewModel>(tag: controllerTag).onPaused();
          Get.back();
          return true;
        },
        child: GetBuilder<PostCardViewModel>(
            init: Get.find<PostCardViewModel>(tag: controllerTag),
            builder: (controller) {
              return Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    titleSpacing: 0,
                    leading: IconButton(
                      onPressed: () {
                        Get.find<PostCardViewModel>(tag: controllerTag).onPaused();
                        Get.back();
                      },
                      icon: const Icon(
                        FontAwesomeIcons.angleLeft,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      controller.post.value.postType!.capitalize!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    actions: [
                      if (controller.post.value.imageUrls!.length > 1)
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 2),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Obx(() => Text(
                                    '${controller.postImageCounter.value}/${controller.post.value.imageUrls!.length}',
                                    style: const TextStyle(color: Colors.white),
                                  )),
                            ))
                    ],
                  ),
                  body: Stack(
                    children: <Widget>[
                      /// Images view
                      if (controller.post.value.captureType ==
                          CaptureType.photo.name)
                        _photoViewWidget(controller),

                      /// Video player view
                      if (controller.post.value.captureType ==
                          CaptureType.video.name)
                        _videoPlayerWidget(controller),

                      /// Posts caption view
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
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
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: ReadMoreText(
                                controller.post.value.caption!,
                                trimLines: 3,
                                colorClickableText:
                                    AppColors.enabledButtonColor,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'more',
                                trimExpandedText: 'less',
                                moreStyle: Get.textTheme.bodyText1!.copyWith(
                                    color: AppColors.disabledButtonColor),
                                style: Get.textTheme.bodyText1!,
                              ),
                            ),
                          ))
                    ],
                  ));
            }),
      ),
    );
  }

  /// Post/Stencil photo view widgets
  Widget _photoViewWidget(PostCardViewModel controller) {
    return Container(
      color: Colors.black,
      child: PageView.builder(
          itemCount: controller.post.value.imageUrls!.length,
          scrollDirection: Axis.horizontal,
          physics: const PageScrollPhysics(),
          onPageChanged: (index) {
            controller.postImageCounter(index + 1);
          },
          itemBuilder: (context, index) {
            return Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      controller.post.value.imageUrls![index],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.grey.withOpacity(0.1),
                  child: PinchZoom(
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 500),
                      imageUrl: controller.post.value.imageUrls![index],
                      fit: BoxFit.fitWidth,
                    ),
                    resetDuration: const Duration(milliseconds: 100),
                    maxScale: 2.5,
                  ),
                ),
              ),
            );
          }),
    );
  }

  /// Post/Stencil video view widgets
  Widget _videoPlayerWidget(PostCardViewModel controller) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: FileImage(
              File(controller.videoThumbnailPath.value)
            ),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Obx(
            () => controller.isVideoControllerInitialized.value
                ? Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
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
          ),
        ));
  }
}
