/// Copyright, 2022, by the authors. All rights reserved.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:inkistry/core/services/firestore_post.dart';
import 'package:inkistry/core/viewmodel/profile_viewmodel.dart';

import '../../model/post_model.dart';
import '../../view/profile/artists_profile_view.dart';
import '../../view/widgets/bottom_sheets/app_bottom_sheets.dart';
import '../services/local_storage_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkistry/view/base/chat_view.dart';
import '../../model/user_model.dart';
import '../../view/base/home_view.dart';
import '../../view/base/profile_view.dart';
import '../../view/base/search_view.dart';
import 'post_card_viewmodel.dart';

/// This class is used to control the viewmodel of the home view.
/// It is used to control the navigation of the home view.
/// It is used to control the navigation of the chat view.
/// It is used to control the navigation of the profile view.
/// It is used to control the navigation of the search view.
class ControlViewModel extends GetxController {
  Rxn<UserModel> currentUser = Rxn<UserModel>();
  String? name, email, password, picUrl;

  /// This variable is used to control the navigation of the home view.
  /// Home view is the first view of the app.
  Widget _currentScreen = const HomeView();

  /// This variable store the current screen index.
  /// Initially it is set to 0.
  int _navigatorIndex = 0;

  /// This variable is used to get the currnetly activated screen.
  Widget get currentScreen => _currentScreen;

  /// This variable is used to get the current screen index.
  int get navigatorIndex => _navigatorIndex;

  // initialize
  @override
  void onInit() {
    getCurrentUser();
    super.onInit();
  }

  getCurrentUser() async {
    currentUser.value = await LocalStorageUser.getUserData();
    Get.put(ProfileViewModel(userId: currentUser.value!.id!),
        tag: currentUser.value!.id!);
    initDynamicLinks();
  }

  /// This method is used to set the current screen.
  changeCurrentScreen(int index) async {
    /// Set the current screen index.
    /// We will update _navigatorIndex to the current screen index
    /// if the current screen index is not equal to 2.
    /// Because there have no view at the index 2.
    /// So when a user click on the index 2, we will not update the _navigatorIndex
    /// and show a bottom sheet.
    if (index != 2) {
      _navigatorIndex = index;
    }

    /// Switch the index and set the current screen.
    switch (index) {
      case 0:

        /// When the index is 0, set the current screen to home view.
        _currentScreen = const HomeView();
        break;
      case 1:

        /// When the index is 1, set the current screen to chat view.
        _currentScreen = const SearchView();
        break;
      case 2:

        /// When the index is 2, open a bottom sheet to select upload posts.
        /// The bottom sheet is used to upload posts, stencils, and images.

        //chooseMediaSheet(context);
        AppBottomSheets.chooseMediaSheet();

        break;
      case 3:

        /// When the index is 3, set the current screen to chat view.
        _currentScreen = const ChatView();
        break;
      case 4:

        /// When the index is 4, set the current screen to profile view.
        _currentScreen = ProfileView(
          controller: Get.find<ProfileViewModel>(tag: currentUser.value!.id!),
        );
        break;
    }

    /// Finally, notify the screen has changed.
    /// This will trigger the screen to change.
    update();
  }

  /// Initialize the dynamicLinks
  Future<void> initDynamicLinks() async {
    // await Future.delayed(const Duration(seconds: 3));

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (data?.link != null) {
      String? postId = data!.link.queryParameters['postId'];
      String? userId = data.link.queryParameters['userId'];

      // Navigate to the post details page
      if (postId != null) {
        DocumentSnapshot postDoc =
            await FirestorePost().getPost(postId: postId);
        PostModel post = PostModel.fromDoc(postDoc);

        Get.put(
            PostCardViewModel(
              post: post,
              currentUser: currentUser.value!,
            ),
            tag: postId);

        Get.find<PostCardViewModel>(tag: postId).navigateToPostDetailsView();
      }

      // Navigate to the user profile page
      if (userId != null && userId != currentUser.value!.id) {
        Get.to(() => ArtistsProfileView(
              controller:
                  Get.put(ProfileViewModel(userId: userId), tag: userId),
            ));
      } else {
        changeCurrentScreen(4);
      }
    }

    FirebaseDynamicLinks.instance.onLink.listen((linkData) async {
      String? postId = linkData.link.queryParameters['postId'];
      String? userId = linkData.link.queryParameters['userId'];

      // Navigate to the post details page
      if (postId != null) {
        DocumentSnapshot postDoc =
            await FirestorePost().getPost(postId: postId);
        PostModel post = PostModel.fromDoc(postDoc);

        Get.put(
            PostCardViewModel(
              post: post,
              currentUser: currentUser.value!,
            ),
            tag: postId);

        Get.find<PostCardViewModel>(tag: postId).navigateToPostDetailsView();
      }

      // Navigate to the user profile page
      if (userId != null && userId != currentUser.value!.id) {
        Get.to(() => ArtistsProfileView(
              controller:
                  Get.put(ProfileViewModel(userId: userId), tag: userId),
            ));
      } else {
        changeCurrentScreen(4);
      }
    }).onError((error) {
      if (kDebugMode) {
        print('onLink error');
      }
      if (kDebugMode) {
        print(error.message);
      }
    });
  }
}
