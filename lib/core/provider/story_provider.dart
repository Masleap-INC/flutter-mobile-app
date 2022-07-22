
import 'package:inkistry/core/values/app_constants.dart';

import '../../model/story_response_model.dart';
import '../api/api_request.dart';
import '../values/app_config.dart';

class StoryProvider {
  void getStories({
    Function()? beforeSend,
    Function(StoryResponseModel storyResponse)? onSuccess,
    Function(dynamic error)? onError,
  }) {
    ApiRequest(url: AppConfig.baseUrl + AppConstants.storiesEndpointPath, data: null).get(
      beforeSend: () => {if (beforeSend != null) beforeSend()},
      onSuccess: (data) {
        onSuccess!(StoryResponseModel.fromJson(data));
      },
      onError: (error) => {if (onError != null) onError(error)},
    );
  }
}
