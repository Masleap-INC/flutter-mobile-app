import 'package:get/get.dart';
import 'package:inkistry/core/services/firestore_chat.dart';
import 'package:inkistry/model/message_model.dart';

import '../../model/user_model.dart';

class MessageBubbleViewModel extends GetxController
    with GetSingleTickerProviderStateMixin {
  final Rx<UserModel> localUser;
  final Rx<UserModel> receiverUser;
  final Rx<MessageModel> message;
  final RxString chatId;

  MessageBubbleViewModel(
      {required UserModel localUser,
      required UserModel receiverUser,
      required MessageModel message,
      required String chatId})
      : localUser = Rx(localUser),
        receiverUser = Rx(receiverUser),
        message = Rx(message), chatId = RxString(chatId);

  RxBool loading = true.obs;
  RxBool isLiked = false.obs;
  RxnBool senderIsMe = RxnBool(null);

  @override
  void onInit() {
    initMessageBubble();
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initMessageBubble() async {
    loading(true);
    senderIsMe(message.value.senderId == localUser.value.id);
    isLiked(message.value.isLiked);
    loading(false);
  }

  likeOrUnlikeMessage() async {
    await FirestoreChat().likeUnlikeMessage(message.value, chatId.value,
        !isLiked.value, receiverUser.value, localUser.value.id!);
    isLiked(!isLiked.value);
  }
}
