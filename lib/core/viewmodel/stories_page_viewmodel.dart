import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/database_references.dart';
import 'package:inkistry/core/viewmodel/home_viewmodel.dart';
import 'package:inkistry/model/story_model.dart';
import 'package:video_player/video_player.dart';

import '../../model/story_response_model.dart';
import '../../model/user_model.dart';
import '../values/app_colors.dart';

class StoriesPageViewModel extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxList<Stories> userStories;
  final Rx<UserModel> currentUser;
  final Rx<UserModel> authorUser;
  final RxInt seenStories;

  StoriesPageViewModel(
      {required List<Stories> userStories,
      required UserModel currentUser,
      required UserModel authorUser,
      required int seenStories,
      bool showUserName = true})
      : userStories = RxList(userStories),
        currentUser = Rx(currentUser),
        authorUser = Rx(authorUser),
        seenStories = RxInt(seenStories);

  final CollectionReference _storiesCollection =
      FirebaseFirestore.instance.collection('stories');

  Rx<Color> circleColor = AppColors.disabledButtonColor.obs;

  PageController? pageController;
  AnimationController? animController;

  RxInt currentIndex = 0.obs;
  RxInt totalSeenStories = 0.obs;

  VideoPlayerController? videoController;
  RxBool isVideoControllerInitialized = false.obs;
  RxBool isVideoPlaying = false.obs;

  @override
  void onInit() {
    _initialization();
    super.onInit();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  void onDispose() {
    animController!.dispose();
    pageController!.dispose();
    if(videoController != null) {
      videoController!.dispose();
    }
    Get.back(result: currentIndex);
  }

  void _initialization() {
    pageController = PageController();
    animController = AnimationController(vsync: this);

    totalSeenStories.value = seenStories.value; // Update;

    if (totalSeenStories.value != 0 &&
        totalSeenStories.value != userStories.length) {
      pageController = PageController(initialPage: totalSeenStories.value);

      currentIndex = totalSeenStories; // Update;

      loadStory(
          story: userStories[totalSeenStories.value].story,
          animateToPage: false);
    } else {
      final StoryModel firstStory = userStories.first.story!;

      loadStory(story: firstStory, animateToPage: false);
    }

    animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animController!.stop();
        animController!.reset();

        if (currentIndex.value + 1 < userStories.length) {
          currentIndex.value++; // Update;
          loadStory(story: userStories[currentIndex.value].story);
        } else {
          // if the stories ended...
          onDispose();
        }
      }
    });
  }

  /// Video player initialize
  Future<VideoPlayerController>? startVideoPlayer(StoryModel story) async {
    isVideoControllerInitialized(false);
    videoController = VideoPlayerController.network(story.videoUrl!);

    videoController!.addListener(() {
      if (!videoController!.value.isPlaying &&
          videoController!.value.isInitialized &&
          (videoController!.value.duration == videoController!.value.position)) {
        //checking the duration and position every time
        // Video Completed
        isVideoPlaying(false);
      }
    });

    videoController!.setLooping(false);
    videoController!.initialize().then((_) {
      isVideoControllerInitialized(true);
    });
    videoController!.play().then((value) {
      isVideoPlaying(true);
    });

    return videoController!;
  }

  void onTapDown(TapUpDetails details) {
    final Size screenSize = Get.size;

    final double dx = details.globalPosition.dx;

    if (dx < screenSize.width / 3) {
      if (currentIndex.value - 1 >= 0) {
        currentIndex.value--;
        if(videoController != null) {
          videoController!.dispose();
        }
        loadStory(story: userStories[currentIndex.value].story);
      }
    } else if (dx > 2 * screenSize.width / 3) {
      if (currentIndex.value + 1 < userStories.length) {
        currentIndex.value++;
        if(videoController != null) {
          videoController!.dispose();
        }
        loadStory(story: userStories[currentIndex.value].story);
      } else {
        // if the user clicks on the story...
        onDispose();
      }
    } else {}
  }

  void loadStory({StoryModel? story, bool animateToPage = true}) {
    animController!.stop();
    animController!.reset();
    animController!.duration = Duration(seconds: story!.duration ?? 10);
    animController!.forward();

    if (animateToPage) {
      pageController!.animateToPage(currentIndex.value,
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
  }

  void onLongPress() {
    animController!.isAnimating
        ? animController!.stop()
        : animController!.forward();
  }

  void onLongPressEnd() {
    animController!.isAnimating
        ? animController!.stop()
        : animController!.forward();
  }

  void setNewStoryView(Stories stories) async {
    final Timestamp timestamp = Timestamp.now();

    StoryModel story = stories.story!;

    Map<dynamic, dynamic>? storyViews = story.views;

    if (!storyViews!.containsKey(currentUser.value.id!)) {
      storyViews[currentUser.value.id!] = timestamp;

      DatabaseReference.users
          .doc(story.authorId)
          .collection('stories')
          .doc(stories.id)
          .update({'views': storyViews}).then(
              (value) => Get.find<HomeViewModel>().updateStories());
    }
  }
}
