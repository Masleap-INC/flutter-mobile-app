import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkistry/core/services/firestore_post.dart';
import 'package:inkistry/model/capture_type.dart';
import 'package:inkistry/model/post_model.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:video_player/video_player.dart';

import '../../model/post_status.dart';
import '../../model/post_type.dart';
import '../../model/user_model.dart';
import '../../view/camera/camera_view.dart';
import '../../view/widgets/dialogs/app_dialogs.dart';
import '../services/local_storage_user.dart';
import '../values/app_colors.dart';
import 'camera_viewmodel.dart';
import 'home_viewmodel.dart';

class CreatePostViewModel extends GetxController {
  final Rx<PostType> postType;
  final Rx<CaptureType> captureType;
  final Rx<String> filePath;

  CreatePostViewModel(
      {required PostType postType,
      required CaptureType captureType,
      required String filePath})
      : postType = Rx(postType),
        captureType = Rx(captureType),
        filePath = Rx(filePath);

  RxList imageFileList = <String>[].obs;
  RxString videoFile = ''.obs;
  Rxn<UserModel> currentUser = Rxn<UserModel>();
  late RichTextController captionTextEditingController;
  RxnString postCaptions = RxnString();
  RxList<UserModel> taggedPeopleList = <UserModel>[].obs;

  RxString stencilsCategory = RxString(PostModel.stencilCatList[0]);

  /// video player for post
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
      // stringMatchMap: {
      //   "Inkistry": const TextStyle(color: AppColors.enabledButtonColor),
      //   "inkistry": const TextStyle(color: AppColors.enabledButtonColor),
      // },
      onMatch: (List<String> matches) {
        // Do something with matches.
        //! P.S
        // as long as you're typing, the controller will keep updating the list.
      },
      deleteOnBack: true,
    );
    _initPostViewModel();
    super.onInit();
  }

  @override
  void dispose() {
    captionTextEditingController.dispose();
    videoController!.dispose();
    super.dispose();
  }

  _initPostViewModel() async {
    if (captureType.value == CaptureType.photo) {
      imageFileList.add(filePath.value);
    } else {
      videoFile.value = filePath.value;
      _startVideoPlayer();
    }

    currentUser.value = await LocalStorageUser.getUserData();
    captionTextEditingController.addListener(() {
      postCaptions.value = captionTextEditingController.text;
    });
  }

  void takeCameraImage() async {
    Get.find<CameraViewModel>().initCamera();
    var result = await Get.to(() => CameraView(
          postType: postType.value,
          captureType: captureType.value,
        ));

    if (result != null) {
      imageFileList.add(result);
    }
  }

  void pickGalleryImage() async {
    final _pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (_pickedFile != null) {
      imageFileList.add(_pickedFile.path);
    }
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

  /// Function for extracting all hashtags
  List<String?> extractHashtags(String text) {
    Iterable<Match> matches = RegExp(r"\B(\#[a-zA-Z]+\b)").allMatches(text);
    return matches.map((m) => m[0]).toList();
  }


  /// Create new post
  void onPostButtonClick() async {
    /// get caption from captionTextEditingController
    String caption = captionTextEditingController.text.toString();

    /// define a map with common keys and values for the both post and stencil
    Map<String, dynamic> data = {
      'authorId': currentUser.value!.id!,
      'taggedPeopleList':
      taggedPeopleList.map((element) => element.id).toList(),
      'hashtags': extractHashtags(caption),
      'caption': caption,
      'likeCount': 0,
      'commentCount': 0,
      'shareCount': 0,
      'location': '',
      'commentsAllowed': true,
      'postType': postType.value.name,
      'captureType': captureType.value.name,
      'status': PostStatus.published.name,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'updateAt': Timestamp.fromDate(DateTime.now())
    };
    /// Image urls used for storing the images url after upload into the firebase storage
    List imageUrls = [];
    /// Video url used for storing the video url after upload into the firebase storage
    String videoUrl = '';

    if(caption.isNotEmpty) {
      /// Show uploading dialogue
      AppDialogs.upload("Uploading ${postType.value.name}. Please wait a few moment...");

      /// Uploading all images file
      if(imageFileList.isNotEmpty) {
        for (var path in imageFileList) {
          String imageUrl = await FirestorePost().uploadImage(File(path));
          imageUrls.add(imageUrl);
        }
      }
      /// Uploading video file
      if(videoFile.isNotEmpty) {
        videoUrl = await FirestorePost().uploadVideo(File(videoFile.value));
      }

      /// Extra properties for post
      if(postType.value == PostType.post ) {
        data['imageUrls'] = imageUrls;
        data['videoUrl'] = videoUrl;
      }
      /// Extra properties for stencil
      else if(postType.value == PostType.stencil) {
        data['imageUrls'] = imageUrls.isNotEmpty?imageUrls : [];
        data['videoUrl'] = videoUrl;
        data['shopName'] = '';
        data['isPremium'] = false;
        data['category'] = stencilsCategory.value;
      }

      /// Create/Upload post/ stencil in firestore
      FirestorePost().createPost(data);
      /// Force update HomeView
      Get.find<HomeViewModel>().update();
      Get.close(2);
    }else {
      Get.snackbar("Message...",
          "You can't create a ${postType.value.name} without caption and images.",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
