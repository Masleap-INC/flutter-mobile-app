import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:inkistry/core/values/app_config.dart';
import 'package:inkistry/view/widgets/bottom_sheets/app_bottom_sheets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../model/capture_type.dart';
import '../../model/post_model.dart';
import '../../model/post_type.dart';
import '../../model/user_model.dart';
import '../../view/camera/camera_view.dart';
import '../../view/post/comments_view.dart';
import '../../view/post/edit_post_view.dart';
import '../../view/post/post_details_view.dart';
import '../services/firestore_post.dart';
import '../services/firestore_user.dart';
import '../values/app_colors.dart';
import 'camera_viewmodel.dart';

class PostCardViewModel extends GetxController  {
  final Rx<UserModel> currentUser;
  final Rx<PostModel> post;

  PostCardViewModel({required UserModel currentUser, required PostModel post})
      : currentUser = Rx(currentUser),
        post = Rx(post);

  Rxn<UserModel> authorUser = Rxn<UserModel>();

  RxBool isLikeLoading = true.obs;
  RxBool isBookLoading = true.obs;
  RxBool showHeartAnim = false.obs;

  RxBool isLiked = false.obs;
  RxBool isBooked = false.obs;

  RxInt likeCount = 0.obs;
  RxInt commentCount = 0.obs;

  RxInt postImageCounter = 1.obs;

  RxList<UserModel> taggedUsersList = <UserModel>[].obs;

  RxString videoThumbnailPath = ''.obs;

  // Comments View
  TextEditingController commentsTextEditingController = TextEditingController();
  RxString commentsImagePath = ''.obs;
  RxString commentsGiphyGifUrl = ''.obs;

  /// video player for post details view
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  RxBool isVideoControllerInitialized = false.obs;
  RxBool isVideoPlaying = false.obs;


  /// Variables for post updates
  RxString stencilsCategory = ''.obs;
  TextEditingController captionTextEditingController = TextEditingController();



  @override
  void onInit() {
    _initLikeCount();
    _initCommentCount();
    _initPostLiked();
    _initPostBooked();
    _getAuthorUser();
    _getAllTaggedUsers();
    _getVideoThumbnail();
    super.onInit();
  }

  @override
  void dispose() {
    commentsTextEditingController.dispose();
    if(videoController != null) {
      videoController!.dispose();
      isVideoControllerInitialized(false);
      isVideoPlaying(false);
    }
    super.dispose();
  }

  void onPaused() {
    if(videoController != null) {
      videoController!.dispose();
      isVideoControllerInitialized(false);
      isVideoPlaying(false);
    }
  }


  _getVideoThumbnail() async {
    if (post.value.captureType == CaptureType.video.name) {
      videoThumbnailPath.value = (await VideoThumbnail.thumbnailFile(
        video: post.value.videoUrl!,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.WEBP,
        // maxHeight: 64,
        quality: 100,
      ))!;
    }
  }

  _getAuthorUser() async {
    DocumentSnapshot userDocSnapshot =
        await FirestoreUser().getUser(post.value.authorId!);
    if (userDocSnapshot.exists) {
      authorUser.value = UserModel.fromDoc(userDocSnapshot);
    }
  }

  _initLikeCount() {
    likeCount = RxInt(post.value.likeCount!);
    isLikeLoading(false);
  }

  _initCommentCount() {
    commentCount = RxInt(post.value.commentCount!);
  }

  _initPostLiked() async {
    isLikeLoading(true);
    bool result = await FirestorePost().getPostIsLiked(
        postId: post.value.id!, currentUserId: currentUser.value.id!);

    isLiked(result);
    isLikeLoading(false);
  }

  _initPostBooked() async {
    isBookLoading(true);
    bool result = await FirestorePost().getPostIsBooked(
        postId: post.value.id!.trim(),
        currentUserId: currentUser.value.id!.trim());

    isBooked(result);
    isBookLoading(false);
  }

  _getAllTaggedUsers() async {
    for (var userId in post.value.taggedPeopleList!) {
      DocumentSnapshot userDocSnapshot = await FirestoreUser().getUser(userId);
      if (userDocSnapshot.exists) {
        taggedUsersList.add(UserModel.fromDoc(userDocSnapshot));
      }
    }
  }

  likePost() async {
    isLikeLoading(true);
    if (!isLiked.value) {
      showHeartAnim(true);
      Timer(const Duration(milliseconds: 300), () {
        showHeartAnim(false);
      });

      int? result = await FirestorePost().likePost(
          postId: post.value.id!,
          author: authorUser.value!,
          currentUser: currentUser.value);

      if (result != null) {
        likeCount(result);
        isLiked(true);
      }
    } else {
      int? result = await FirestorePost().unlikePost(
          postId: post.value.id!,
          author: authorUser.value!,
          currentUser: currentUser.value);
      if (result != null) {
        likeCount(result);
        isLiked(false);
      }
    }
    isLikeLoading(false);
  }

  bookPost() async {
    isBookLoading(true);
    if (!isBooked.value) {
      bool result = FirestorePost().createBookmark(
          post: post.value, currentUser: currentUser.value);
      if (result) {
        isBooked(true);
      }
    } else {
      FirestorePost().removeBookmark(
          postId: post.value.id!, currentUserId: currentUser.value.id!);
      isBooked(false);
    }
    isBookLoading(false);
  }

  /// Video player
  Future<void> _startVideoPlayer() async {
    if (post.value.videoUrl!.isEmpty) {
      return;
    }

    isVideoControllerInitialized(false);
    isVideoPlaying(true);

    videoController = VideoPlayerController.network(post.value.videoUrl!);

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

  /// Comments functions
  pickImagesUsingCamera() async {
    Get.find<CameraViewModel>().initCamera();
    var result = await Get.to(() => const CameraView(
          postType: PostType.story,
          captureType: CaptureType.photo,
        ));

    if (result != null) {
      commentsGiphyGifUrl('');
      commentsImagePath(result);
    }
  }

  getGiphyGif() async {
    GiphyGif? gif = await GiphyGet.getGif(
        context: Get.context!,
        apiKey: AppConfig.giphyGifApiKey,
        lang: GiphyLanguage.english,
        tabColor: AppColors.enabledButtonColor);
    if (gif != null) {
      commentsImagePath('');
      commentsGiphyGifUrl(gif.images!.original!.url);
    }
  }

  commentOnPost() async {
    String comments = commentsTextEditingController.text.toString();
    if (comments.isNotEmpty ||
        commentsGiphyGifUrl.value.isNotEmpty ||
        commentsImagePath.value.isNotEmpty) {
      String imageUrl = '';

      if (commentsGiphyGifUrl.value.isNotEmpty) {
        imageUrl = commentsGiphyGifUrl.value;
      } else if (commentsImagePath.value.isNotEmpty) {
        imageUrl =
            await FirestorePost().uploadImage(File(commentsImagePath.value));
      }

      Map<String, dynamic> data = {
        'authorId': currentUser.value.id!,
        'comments': comments,
        'imageUrl': imageUrl,
        'likeCount': 0,
        'replyCount': 0,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      FirestorePost().createComment(
          postId: post.value.id!, authorId: currentUser.value.id!, data: data);

      // Increment the comment counter
      commentCount.value++;
      // reset values
      commentsTextEditingController.clear();
      commentsGiphyGifUrl('');
      commentsImagePath('');
    } else {
      Get.snackbar("Message...", "Comment may not be empty.",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Post card context menu action functions
  sharePostWithFriend() async{
    // String postLink = await createDynamicLink();
  }

  copyPostLink() async{
    Get.back();
    String postLink = await FirestorePost().createDynamicLink(currentUser.value, post.value);
    Clipboard.setData(ClipboardData(text: postLink)).then((_){
      Get.snackbar("Copy link...", "Link Copied to Clipboard.", snackPosition: SnackPosition.BOTTOM);
    });
  }

  moveToTrash() {
    Get.back();
    bool result = FirestorePost().moveToTrash(post: post.value, currentUser: currentUser.value);
    if(result){
      Get.snackbar("Trash...", "Post moved to trash.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  hidePost() {
    Get.back();
    bool result = FirestorePost().hideFeedPost(post: post.value, currentUser: currentUser.value);
    if(result){
      Get.snackbar("Hide post...", "Post hidden from the feed.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  moveToArchive() {
    Get.back();
    bool result = FirestorePost().moveToArchive(post: post.value, currentUser: currentUser.value);
    if(result){
      Get.snackbar("Archive...", "Post moved to archive.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  saveInkistryPhoto() async {
    Get.back();
    try {

      if(post.value.imageUrls!.isNotEmpty) {
        for(var imageUrl in post.value.imageUrls!) {
          await GallerySaver.saveImage(imageUrl);

        }
      }

      if(post.value.videoUrl!.isNotEmpty) {
        await GallerySaver.saveVideo(post.value.videoUrl!);
      }

      Get.snackbar("Saved...", "Photo saved successfully", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error...", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }


  /// Navigator functions
  navigateToAuthorProfileView() {
    // if(widget.currentUser.id != widget.author.id){
    //   Get.to(()=>ArtistProfilePage(currentUser: widget.author,));
    // }else{
    //   Get.put(MainPageController()).currentIndex.value = 3;
    // }
  }

  navigateToPostDetailsView() {
    _startVideoPlayer();
    Get.to(() => PostDetailsView(
      controllerTag: post.value.id!,
    ));
  }

  navigateToEditPostPage() async {
    stencilsCategory(post.value.category);
    captionTextEditingController.text = post.value.caption!;

    Get.off(() => EditPostView(
      controllerTag: post.value.id!,
    ));
  }

  navigateToCommentsView() {
    Get.to(() => CommentsView(
          controllerTag: post.value.id!,
        ));
  }

  openPostContextMenu() {
    AppBottomSheets.postCardActionSheet(controllerTag: post.value.id!);
  }

  /// Stencils form page
  stencilTryNow() {}


  /// Edit post
  saveEditedPost() async {

    String caption = captionTextEditingController.text.toString();

    Map<String, dynamic> data = {};

    data['caption'] = caption.isNotEmpty ? caption: post.value.caption;

    if(post.value.postType == PostType.stencil.name) {
      data['category'] = stencilsCategory.value;
    }

    FirestorePost().updatePost(postId: post.value.id!, data: data);

    Get.snackbar("Info...", "Post updated successfully!", snackPosition: SnackPosition.BOTTOM);

  }

}
