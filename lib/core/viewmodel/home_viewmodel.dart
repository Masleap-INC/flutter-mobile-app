import 'package:get/get.dart';
import 'package:inkistry/core/provider/story_provider.dart';
import 'package:inkistry/model/story_response_model.dart';

import '../../model/capture_type.dart';
import '../../model/post_type.dart';
import '../../model/user_model.dart';
import '../../view/camera/camera_view.dart';
import '../../view/post/create_story_view.dart';
import '../services/local_storage_user.dart';
import 'camera_viewmodel.dart';
import 'create_story_viewmodel.dart';

class HomeViewModel extends GetxController {
  UserModel? _currentUser;

  List<StoryResponse> storyResponseList = <StoryResponse>[];

  RxBool loading = false.obs;

  UserModel get currentUser => _currentUser!;

  RxBool isListViewType = true.obs;

  //bool doesCurrentUserHasStories = false;

  @override
  void onInit() {
    _getFollowingUsersStories();

    super.onInit();
  }

  _getFollowingUsersStories() async {
    loading(true);
    _currentUser = await LocalStorageUser.getUserData();
    StoryProvider().getStories(
      onSuccess: (response) {
        storyResponseList = response.response!;

        loading(false);
        update();
      },
      onError: (error) {
        loading(false);
      },
    );
  }

  updateStories() async {
    StoryProvider().getStories(
      onSuccess: (response) {
        storyResponseList = response.response!;
        update();
      },
    );
  }

  createANewStory() async {
    Get.find<CameraViewModel>().initCamera();

    PostType postType = PostType.story;
    CaptureType captureType = CaptureType.photo;

    var result = await Get.to(() => CameraView(
          postType: postType,
          captureType: captureType,
        ));

    if (result != null) {
      Get.to(() => CreateStoryView(
          controller: Get.put(CreateStoryViewModel(
              postType: postType,
              captureType: captureType,
              filePath: result))));
    }
  }
}
