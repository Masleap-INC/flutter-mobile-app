import 'package:get/get.dart';

import '../core/network_viewmodel.dart';
import '../core/viewmodel/activity_viewmodel.dart';
import '../core/viewmodel/auth_viewmodel.dart';
import '../core/viewmodel/camera_viewmodel.dart';
import '../core/viewmodel/chat_viewmodel.dart';
import '../core/viewmodel/home_viewmodel.dart';
import '../view/widgets/bottom_sheets/post_type_widget.dart';

class Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthViewModel());
    Get.lazyPut(() => NetworkViewModel());
    Get.lazyPut(() => HomeViewModel());
    Get.lazyPut(() => ActivityViewModel());
    Get.lazyPut(() => CameraViewModel());
    Get.lazyPut(() => PostTypeController());
    Get.lazyPut(() => ChatViewModel());
  }
}
