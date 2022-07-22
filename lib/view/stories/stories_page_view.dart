import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

import '../../core/viewmodel/stories_page_viewmodel.dart';
import '../../model/capture_type.dart';
import '../../model/story_model.dart';
import '../widgets/stories/animated_bar_widget.dart';
import '../widgets/user/user_avatar_widget.dart';
import '../widgets/user/user_badges_widget.dart';

class StoryPageView extends StatelessWidget {
  final StoriesPageViewModel controller;

  const StoryPageView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return WillPopScope(
      onWillPop: () async {
        controller.onDispose();
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Container(
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
                    1.0,
                    0.75,
                    0.5,
                    0.25,
                    0.0,
                  ]),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: REdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: controller.userStories
                          .asMap()
                          .map((i, e) {
                        return MapEntry(
                          i,
                          Obx(() => AnimatedBarWidget(
                            animationController: controller.animController!,
                            position: i,
                            currentIndex: controller.currentIndex.value,
                          )),
                        );
                      }).values.toList(),
                    ),
                  ),
                ),
                Positioned(
                  top: 11,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Padding(
                      padding: REdgeInsets.only(left: 15),
                      child: UserAvatarWidget(
                        users: controller.authorUser.value,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.authorUser.value.name!,
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            UserBadgesWidget(user: controller.authorUser.value, size: 20),
                          ],
                        ),
                        Obx(() => Text(
                          timeago.format(
                              controller.userStories[controller.currentIndex.value].story!
                                  .timeStart!
                                  .toDate(),
                              locale: 'en_short'),
                          style: const TextStyle(color: Colors.white),
                        )),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.times, color: Colors.white70),
                        onPressed: () {
                          controller.onDispose();
                        },
                      ),

                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: GestureDetector(
          onTapUp: (details) => controller.onTapDown(details),
          onLongPress: () => controller.onLongPress(),
          onLongPressEnd: (details) => controller.onLongPressEnd(),
          child: PageView.builder(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.userStories.length,
            itemBuilder: (context, index) {
              final StoryModel story = controller.userStories[index].story!;

              controller.setNewStoryView(controller.userStories[index]);

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (story.captureType == CaptureType.photo.name)
                    CachedNetworkImage(
                      imageUrl: story.imageUrl!,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 500),
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) {
                        return Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress),
                        );
                      },
                    ),
                  if (story.captureType == CaptureType.video.name &&
                      story.videoUrl != null)
                    FutureBuilder<VideoPlayerController>(
                        future: controller.startVideoPlayer(story),
                        builder: (context, snapshot) {
                          return Obx(() => controller
                                  .isVideoControllerInitialized.value
                              ? Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          height:
                                              snapshot.data!.value.size.height,
                                          width:
                                              snapshot.data!.value.size.width,
                                          child: VideoPlayer(snapshot.data!),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                ));
                        }),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.caption!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontFamily: "SofiaPro",
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ))
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
