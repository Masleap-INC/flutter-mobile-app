import 'dart:ui';
import 'package:get/get.dart';

import '../../model/story_response_model.dart';
import '../../model/user_model.dart';
import '../values/app_colors.dart';

class StoriesViewModel extends GetxController {
  final RxList<Stories> userStories;
  final Rx<UserModel> currentUser;
  final Rx<UserModel> authorUser;
  final RxDouble size;
  final RxBool showUserName;
  int seenStories = 0;

  StoriesViewModel(
      {required List<Stories> userStories,
      required UserModel currentUser,
      required UserModel authorUser,
      double size = 60,
      bool showUserName = true})
      : userStories = RxList(userStories),
        currentUser = Rx(currentUser),
        authorUser = Rx(authorUser),
        size = RxDouble(size),
        showUserName = RxBool(showUserName);

  Rx<Color> circleColor = AppColors.disabledButtonColor.obs;

  @override
  void onInit() {
    _checkForSeenStories();
    super.onInit();
  }

  void _checkForSeenStories() {
    for (Stories story in userStories) {
      if (story.story!.views!.containsKey(currentUser.value.id)) {
        seenStories++;
      }
    }

    if (seenStories == userStories.length) {
      circleColor.value = AppColors.disabledButtonColor;
    } else {
      circleColor.value = AppColors.enabledButtonColor;
    }
  }
}
