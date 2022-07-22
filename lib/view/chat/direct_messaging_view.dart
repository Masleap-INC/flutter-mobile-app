import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/services/firestore_user.dart';
import 'package:inkistry/core/values/system_overlay.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/database_query.dart';
import '../../core/viewmodel/direct_message_viewmodel.dart';
import '../../core/viewmodel/message_bubble_viewmodel.dart';
import '../../model/message_model.dart';
import '../../model/user_model.dart';
import '../widgets/chat/message_bubble_widget.dart';

class DirectMessageView extends StatelessWidget {
  final DirectMessageViewModel controller;

  const DirectMessageView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: Obx(() => controller.loading.value
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Scaffold(
        backgroundColor: AppColors.secondaryBackground(Get.isDarkMode),
              appBar: AppBar(
                elevation: 0,
                //backgroundColor: Colors.transparent,
                titleSpacing: 0,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    FontAwesomeIcons.angleLeft,
                  ),
                ),
                title: Obx(() => controller.isGroupChat.value
                    ? const Text("Group Chat")
                    : Text(controller.receiverUsers[controller.receiverIndex].name!)),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(() => controller.isChatExist.value
                        ? PaginateFirestore(
                            itemBuilder: (context, documentSnapshots, index) {
                              MessageModel message = MessageModel.fromDoc(
                                  documentSnapshots[index]);


                              return FutureBuilder(
                                future: FirestoreUser().getUser(message.senderId!),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if(!snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }

                                  UserModel receiverUser = UserModel.fromDoc(snapshot.data);

                                  return MessageBubbleWidget(
                                    controller: Get.put(
                                        MessageBubbleViewModel(
                                          chatId: controller.chatData.value.id!,
                                          localUser: controller.localUser.value,
                                          receiverUser: receiverUser,
                                          message: message,
                                        ),
                                        tag: UniqueKey().toString(),),
                                    key: UniqueKey(),
                                  );
                                }
                              );
                            },
                            query: FirestoreQueries.directMessageQuery(
                                controller.chatData.value.id!),
                            itemBuilderType: PaginateBuilderType.listView,
                            isLive: true,
                            reverse: true,
                            key: UniqueKey(),
                          )
                        : const Center(
                            child: Text("Start messaging"),
                          )),
                  ),
                  Obx(() => controller.messageImagePath.value.isNotEmpty
                      ? _pickedImageView()
                      : const SizedBox.shrink()),
                  Obx(() => controller.messageGiphyGifUrl.value.isNotEmpty
                      ? _giphyGifView()
                      : const SizedBox.shrink()),
                  _messageTextField()
                ],
              ),
            )),
    );
  }

  Widget _messageTextField() {
    return Padding(
        padding: REdgeInsets.all(15),
        child: TextField(
          controller: controller.messageTextEditingController,
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: "Type a message..",
            labelText: "Message",
            prefixIcon: Wrap(
              direction: Axis.horizontal,
              children: [
                IconButton(
                    padding: REdgeInsets.fromLTRB(12, 12, 8, 12),
                    constraints: const BoxConstraints(),
                    onPressed: () => controller.pickImagesUsingCamera(),
                    icon: Icon(
                      FontAwesomeIcons.camera,
                      color: Get.textTheme.bodyText2!.color,
                    )),
                IconButton(
                    padding: REdgeInsets.fromLTRB(0, 12, 8, 12),
                    constraints: const BoxConstraints(),
                    onPressed: () => controller.getGiphyGif(),
                    icon: Icon(
                      FontAwesomeIcons.solidSmile,
                      size: 24,
                      color: Get.textTheme.bodyText2!.color,
                    ))
              ],
            ),
            suffixIcon: IconButton(
                onPressed: () => controller.sendMessage(),
                icon: Icon(
                  FontAwesomeIcons.solidPaperPlane,
                  color: Get.textTheme.bodyText2!.color,
                )),
          ),
          style: Get.textTheme.bodyText2,
        ));
  }

  /// Image view
  Widget _pickedImageView() {
    return Padding(
      padding: REdgeInsets.only(left: 15),
      child: Stack(
        children: <Widget>[
          Container(
            width: 101.w,
            height: 95.h,
            margin: REdgeInsets.only(top: 10, right: 10),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(
                    File(controller.messageImagePath.value),
                  ),
                  fit: BoxFit.cover),
              border:
                  Border.all(color: AppColors.disabledButtonColor, width: 2),
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 30.r,
                width: 30.r,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: AppColors.disabledButtonColor, width: 2),
                    borderRadius: BorderRadius.circular(15.r)),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.r),
                    splashColor: Colors.redAccent.withOpacity(0.5),
                    child: const Icon(
                      FontAwesomeIcons.times,
                      color: AppColors.disabledButtonColor,
                      size: 22,
                    ),
                    onTap: () {
                      controller.messageImagePath('');
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// GiphyGif view
  Widget _giphyGifView() {
    return Padding(
      padding: REdgeInsets.only(left: 15),
      child: Stack(
        children: <Widget>[
          Container(
            width: 101.w,
            height: 95.h,
            margin: REdgeInsets.only(top: 10, right: 10),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                    controller.messageGiphyGifUrl.value,
                  ),
                  fit: BoxFit.cover),
              border:
                  Border.all(color: AppColors.disabledButtonColor, width: 2),
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 30.r,
                width: 30.r,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: AppColors.disabledButtonColor, width: 2),
                    borderRadius: BorderRadius.circular(15.r)),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.r),
                    splashColor: Colors.redAccent.withOpacity(0.5),
                    child: const Icon(
                      FontAwesomeIcons.times,
                      color: AppColors.disabledButtonColor,
                      size: 22,
                    ),
                    onTap: () {
                      controller.messageGiphyGifUrl('');
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
