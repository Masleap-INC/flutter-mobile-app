import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giphy_get/giphy_get.dart';
import '../../model/capture_type.dart';
import '../../model/chat_model.dart';
import '../../model/message_model.dart';
import '../../model/post_type.dart';
import '../../model/user_model.dart';
import '../../view/camera/camera_view.dart';
import '../services/firestore_chat.dart';
import '../values/app_colors.dart';
import '../values/app_config.dart';
import 'camera_viewmodel.dart';

class DirectMessageViewModel extends GetxController {
  final Rx<UserModel> localUser;
  final RxList<UserModel> receiverUsers;

  DirectMessageViewModel(
      {required UserModel localUser, required List<UserModel> receiverUsers})
      : localUser = Rx(localUser),
        receiverUsers = RxList(receiverUsers);

  ///  Chat message
  List<String> userIds = [];
  List<UserModel> users = [];
  Rx<ChatModel> chatData = Rx(ChatModel());

  /// Loader
  RxBool loading = true.obs;
  RxBool sending = false.obs;
  RxBool isComposingMessage = false.obs;
  RxBool isChatExist = false.obs;

  /// TextEditingController
  final TextEditingController messageTextEditingController =
      TextEditingController();
  RxString messageImagePath = ''.obs;
  RxString messageGiphyGifUrl = ''.obs;


  RxBool isGroupChat = false.obs;
  int receiverIndex = 0;


  @override
  void onInit() {
    initDirectMessage();
    super.onInit();
  }

  @override
  void dispose() {
    messageTextEditingController.dispose();
    super.dispose();
  }

  initDirectMessage() async {
    loading(true);

    // userIds.add(localUser.value.id!);
    userIds.addAll(receiverUsers.map((e) => e.id!).toList());

    // users.add(localUser.value);
    users.addAll(receiverUsers);

    receiverIndex = users.indexWhere((user) => user.id != localUser.value.id);

    if (users.length > 2) {
      isGroupChat(true);
    }

    ChatModel? chat = await FirestoreChat().getChatByUsers(userIds);

    if (chat != null) {
      FirestoreChat().setChatRead(localUser.value.id!, chat, true);

      ChatModel chatWithMemberInfo = ChatModel(
        id: chat.id,
        memberIds: chat.memberIds,
        memberInfo: users,
        readStatus: chat.readStatus,
        recentMessage: chat.recentMessage,
        recentSender: chat.recentSender,
        recentTimestamp: chat.recentTimestamp,
      );

      chatData(chatWithMemberInfo);
    }

    isChatExist(chat != null);
    loading(false);
  }

  Future<void> createChat(userIds) async {
    ChatModel chat =
        await FirestoreChat().createChat(localUser.value.id!, users, userIds);
    chatData(chat);
    isChatExist(true);
  }

  ///
  /// Comments functions
  pickImagesUsingCamera() async {
    Get.find<CameraViewModel>().initCamera();
    var result = await Get.to(() => const CameraView(
          postType: PostType.story,
          captureType: CaptureType.photo,
        ));

    if (result != null) {
      messageGiphyGifUrl('');
      messageImagePath(result);
    }
  }

  getGiphyGif() async {
    GiphyGif? gif = await GiphyGet.getGif(
        context: Get.context!,
        apiKey: AppConfig.giphyGifApiKey,
        lang: GiphyLanguage.english,
        tabColor: AppColors.enabledButtonColor);
    if (gif != null) {
      messageImagePath('');
      messageGiphyGifUrl(gif.images!.original!.url);
    }
  }

  sendMessage() async {
    String messageText = messageTextEditingController.text.toString();

    if (messageText.isNotEmpty ||
        messageGiphyGifUrl.value.isNotEmpty ||
        messageImagePath.value.isNotEmpty) {
      String imageUrl = '';

      if (messageGiphyGifUrl.value.isNotEmpty) {
        imageUrl = messageGiphyGifUrl.value;
      } else if (messageImagePath.value.isNotEmpty) {
        imageUrl = await FirestoreChat()
            .uploadMessageImage(File(messageImagePath.value));
      }

      sending(true);

      if (!isChatExist.value) {
        await createChat(userIds);
      }

      isComposingMessage(false);

      MessageModel message = MessageModel(
        senderId: localUser.value.id,
        text: messageText,
        imageUrls: imageUrl.isEmpty ? [] : [imageUrl],
        giphyUrl: '',
        timeCreated: Timestamp.now(),
        isLiked: false,
      );

      FirestoreChat()
          .sendChatMessage(chatData.value, message, receiverUsers);

      sending(false);

      // reset values
      messageTextEditingController.clear();
      messageGiphyGifUrl('');
      messageImagePath('');
    } else {
      Get.focusScope!.unfocus();
    }
  }
}
