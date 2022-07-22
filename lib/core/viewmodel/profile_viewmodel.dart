import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkistry/core/values/database_query.dart';
import 'package:inkistry/view/widgets/dialogs/app_dialogs.dart';
import '../../model/post_history_type.dart';
import '../../model/user_model.dart';
import '../../view/post/post_history_view.dart';
import '../../view/profile/followers_and_following_view.dart';
import '../../view/settings/settings_view.dart';
import '../../view/widgets/user/artist_cards/search_artist_card_widget.dart';
import '../services/firestore_user.dart';
import '../services/local_storage_user.dart';

class ProfileViewModel extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxString userId;

  ProfileViewModel({required String userId}) : userId = RxString(userId);

  /// Tab controller for changing post and bookmark tabs
  late TabController tabController;

  /// Rxn UserModel observable variable for storing the user info
  Rxn<UserModel> localUser = Rxn<UserModel>();
  Rxn<UserModel> remoteUser = Rxn<UserModel>();

  RxBool loading = false.obs;

  RxInt postCount = 0.obs;
  RxInt stencilsCount = 0.obs;
  RxInt followerCount = 0.obs;
  RxInt followingCount = 0.obs;
  RxDouble ratingsCount = 0.0.obs;

  /// For edit profile
  RxString coverImagePath = ''.obs;
  RxString profileImagePath = ''.obs;
  String name = '';
  String bio = '';

  @override
  void onInit() {
    super.onInit();

    getLocalUser();
    initRemoteUser();
  }

  @override
  void dispose() {
    /// Disposing the tabController
    tabController.dispose();
    super.dispose();
  }

  getLocalUser() async {
    loading(true);
    localUser(await LocalStorageUser.getUserData());

    if (localUser.value!.id! == userId.value) {
      tabController = TabController(vsync: this, length: 2);
      remoteUser = localUser;
      postCount(remoteUser.value!.postCount!.toInt());
      stencilsCount(remoteUser.value!.stencilsCount!.toInt());
      followerCount(remoteUser.value!.followerCount!.toInt());
      followingCount(remoteUser.value!.followingCount!.toInt());
      ratingsCount(remoteUser.value!.ratingCount!.toDouble());
      loading(false);
      update();
    } else {
      tabController = TabController(vsync: this, length: 3);
    }
    initRemoteUser();
  }

  initRemoteUser() async {
    DocumentSnapshot userDocSnapshot =
        await FirestoreUser().getUser(userId.value);
    remoteUser(UserModel.fromDoc(userDocSnapshot));
    postCount(remoteUser.value!.postCount!.toInt());
    stencilsCount(remoteUser.value!.stencilsCount!.toInt());
    followerCount(remoteUser.value!.followerCount!.toInt());
    followingCount(remoteUser.value!.followingCount!.toInt());
    ratingsCount(remoteUser.value!.ratingCount!.toDouble());
    loading(false);
    
    if (localUser.value!.id! != remoteUser.value!.id!) {
      _initArtistFollowingStatus();
    }else {
      LocalStorageUser.setUserData(remoteUser.value!);
    }

    update();
  }

  /// init following or not
  RxnBool isFollowed = RxnBool();

  /// Follow Artist section
  _initArtistFollowingStatus() async {
    loading(true);

    if (localUser.value!.id != remoteUser.value!.id!) {
      bool result = await FirestoreUser().getUserIsFollowed(
          artistId: remoteUser.value!.id!, currentUserId: localUser.value!.id!);
      isFollowed(result);
    }

    loading(false);
  }

  followThisArtist() async {
    FirestoreUser().followUser(
        artistUser: remoteUser.value!, currentUser: localUser.value!);
    Get.find<ProfileViewModel>(tag: localUser.value!.id!)
        .followingCount
        .value++;

    Get.find<SearchArtistCardViewModel>(tag: remoteUser.value!.id!)
        .isFollowed(true);
    followerCount.value++;
    isFollowed(true);
  }

  unfollowThisArtist() async {
    FirestoreUser().unfollowUser(
        artistUser: remoteUser.value!, currentUser: localUser.value!);
    Get.find<ProfileViewModel>(tag: localUser.value!.id!)
        .followingCount
        .value--;
    followerCount.value--;
    Get.find<SearchArtistCardViewModel>(tag: remoteUser.value!.id!)
        .isFollowed(false);
    isFollowed(false);
  }

  void pickCoverImage() async {
    final _pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (_pickedFile != null) {
      coverImagePath(_pickedFile.path);
    }
  }

  void pickProfileImage() async {
    final _pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (_pickedFile != null) {
      profileImagePath(_pickedFile.path);
    }
  }

  /// update this artist with the new information
  updateTheArtist() async {

    AppDialogs.upload("Updating profile information");
    
    if (profileImagePath.value.isNotEmpty) {
      await FirestoreUser().uploadUserProfileImageFromFile(
          localUser.value!.imageUrl!.isNotEmpty
              ? localUser.value!.imageUrl!
              : null,
          File(profileImagePath.value));
    }

    if (coverImagePath.value.isNotEmpty) {
      await FirestoreUser().uploadUserCoverImageFromFile(
          localUser.value!.coverImageUrl!.isNotEmpty
              ? localUser.value!.coverImageUrl!
              : null,
          File(coverImagePath.value));
    }

    Map<String, dynamic> data = {
      'name': name != remoteUser.value!.name ? name : remoteUser.value!.name,
      'bio': bio != remoteUser.value!.bio ? bio : remoteUser.value!.bio,
    };

    FirestoreUser().updateUserInformation(localUser.value!, data);
    
    initRemoteUser();

    coverImagePath('');
    profileImagePath('');

    Get.back();
  }

  /// Bottom sheets navigation functions
  navigateToSettingsPostPage() async {
    Get.off(const SettingsView());
  }

  navigateToArtistsRatingPage() async {
    Get.snackbar("Message...", "No implemented!",
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(10));
  }

  copyProfileLink() async {
    Get.back();
    String profileLink =
        await FirestoreUser().createDynamicLink(remoteUser.value!);
    Clipboard.setData(ClipboardData(text: profileLink)).then((_) {
      Get.snackbar("Copy link...", "Link Copied to Clipboard.",
          snackPosition: SnackPosition.BOTTOM);
    });
  }

  navigateToSavedPostPage() async {
    Get.back();
    tabController.animateTo(1);
  }

  navigateToArchivedPostPage() async {
    Get.to(PostHistoryView(
      query: FirestoreQueries.artistsArchivedPosts(remoteUser.value!.id!),
      type: PostHistoryType.archived,
    ));
  }

  navigateToActivityPage() async {}

  navigateToHiddenPostPage() async {
    Get.to(PostHistoryView(
      query: FirestoreQueries.artistsHiddenPosts(remoteUser.value!.id!),
      type: PostHistoryType.hidden,
    ));
  }

  navigateToDeletedPostPage() async {
    Get.to(PostHistoryView(
      query: FirestoreQueries.artistsDeletedPosts(remoteUser.value!.id!),
      type: PostHistoryType.deleted,
    ));
  }

  ///
  navigateToFollowersAndFollowingPage(int index) {
    Get.to(FollowersAndFollowingView(
      controller: Get.put(
          FollowersAndFollowingViewModel(
              index: index, remoteUser: remoteUser.value!),
          tag: UniqueKey().toString()),
    ));
  }
}
