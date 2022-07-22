import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/services/firestore_post.dart';
import 'package:inkistry/model/capture_type.dart';
import 'package:inkistry/view/widgets/dialogs/app_dialogs.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:video_player/video_player.dart';

import '../../model/post_status.dart';
import '../../model/post_type.dart';
import '../../model/user_model.dart';
import '../services/local_storage_user.dart';
import '../values/app_colors.dart';
import 'home_viewmodel.dart';

class CreateStoryViewModel extends GetxController {
  final Rx<PostType> postType;
  final Rx<CaptureType> captureType;
  final Rx<String> filePath;

  CreateStoryViewModel(
      {required PostType postType,
      required CaptureType captureType,
      required String filePath})
      : postType = Rx(postType),
        captureType = Rx(captureType),
        filePath = Rx(filePath);

  RxString imageFile = ''.obs;
  RxString videoFile = ''.obs;
  Rxn<UserModel> currentUser = Rxn<UserModel>();
  late RichTextController captionTextEditingController;
  RxnString storyCaptions = RxnString();
  RxList<UserModel> taggedPeopleList = <UserModel>[].obs;

  /// video player for story
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  RxBool isVideoControllerInitialized = false.obs;
  RxBool isVideoPlaying = false.obs;

  @override
  void onInit() {
    captionTextEditingController = RichTextController(
      patternMatchMap: {
        //Hashtag
        RegExp(r"\B#[a-zA-Z0-9]+\b"):
            const TextStyle(color: AppColors.appColorBlue),
        //Mention
        RegExp(r"\B@[a-zA-Z0-9]+\b"): const TextStyle(
          color: AppColors.disabledButtonColor,
        ),
      },
      onMatch: (List<String> matches) {},
      deleteOnBack: true,
    );
    _initStoryViewModel();
    super.onInit();
  }

  @override
  void dispose() {
    captionTextEditingController.dispose();
    super.dispose();
  }

  _initStoryViewModel() async {

    if (captureType.value == CaptureType.photo) {
      imageFile.value = filePath.value;
    } else {
      videoFile.value = filePath.value;
      _startVideoPlayer();
    }

    currentUser.value = await LocalStorageUser.getUserData();
    captionTextEditingController.addListener(() {
      storyCaptions.value = captionTextEditingController.text;
    });
  }

  /// Video player
  Future<void> _startVideoPlayer() async {
    if (videoFile.value.isEmpty) {
      return;
    }

    videoController = VideoPlayerController.file(File(videoFile.value));

    videoController!.addListener(() {
      if (!videoController!.value.isPlaying && videoController!.value.isInitialized &&
          (videoController!.value.duration ==videoController!.value.position)) { //checking the duration and position every time
        //Video Completed//
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

  }

  void onPostButtonClick() async {
    /// Get current datetime
    final DateTime dateNow = DateTime.now();
    /// Add one day to the datetime
    DateTime dateThen = dateNow.add(const Duration(days: 1));
    /// Convert current datetime to firestore timestamp
    final Timestamp timeStart = Timestamp.fromDate(dateNow);
    /// Convert the incremented datetime to firestore timestamp
    final Timestamp timeEnd = Timestamp.fromDate(dateThen);

    /// get caption from captionTextEditingController
    String caption = captionTextEditingController.text.toString();

    /// define a map with common keys and values for the both post and stencil
    Map<String, dynamic> data = {
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'authorId': currentUser.value!.id!,
      'imageUrl': '',
      'videoUrl': '',
      'caption': caption,
      'views': {},
      'location': '',
      'filter': '',
      'linkUrl': '',
      'postType': postType.value.name,
      'captureType': captureType.value.name,
      'status': PostStatus.published.name
    };

    /// Image url used for storing the image url after upload into the firebase storage
    String imageUrl = '';
    /// Video url used for storing the video url after upload into the firebase storage
    String videoUrl = '';

    if(caption.isNotEmpty) {
      /// Show uploading dialogue
      AppDialogs.upload("Uploading ${postType.value.name}. Please wait a few moment...");

      /// Uploading all images file
      if(imageFile.isNotEmpty) {
        imageUrl = await FirestorePost().uploadImage(File(imageFile.value));
      }
      /// Uploading video file
      if(videoFile.isNotEmpty) {
        videoUrl = await FirestorePost().uploadVideo(File(videoFile.value));
      }

      /// Video duration for the story
      if(captureType.value == CaptureType.video && videoController != null) {
        data['duration'] = videoController!.value.duration;
      }

      /// Extra properties
      data['imageUrl'] = imageUrl;
      data['videoUrl'] = videoUrl;

      /// Create story in the Firestore
      FirestorePost().createStory(authorId: currentUser.value!.id!, data: data);
      /// Fetch stories list in home view
      Get.find<HomeViewModel>().updateStories();
      Get.close(2);

    }else {
      Get.snackbar("Message...",
          "You can't create a ${postType.value.name} without caption and images.",
          margin: REdgeInsets.all(15),
          snackPosition: SnackPosition.BOTTOM);
    }

  }
}
