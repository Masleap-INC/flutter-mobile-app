import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/services/firestore_chat.dart';
import '../../core/services/local_storage_user.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_images.dart';
import '../../core/values/database_query.dart';
import '../../core/values/system_overlay.dart';
import '../../model/chat_model.dart';
import '../../model/message_model.dart';
import '../../model/user_model.dart';
import '../widgets/dialogs/app_dialogs.dart';
import '../widgets/user/artist_cards/chat_group_artist_card_widget.dart';

class CreateChatGroupViewModel extends GetxController {


  RxBool loading = true.obs;
  RxBool sending = false.obs;

  Rxn<UserModel> localUser = Rxn(null);
  RxList<UserModel> receiverUsers = <UserModel>[].obs;

  TextEditingController messageTextEditingController = TextEditingController();

  @override
  void onInit() {
    initCreateChatGroupViewModel();
    super.onInit();
  }

  @override
  void dispose() {
    messageTextEditingController.dispose();
    super.dispose();
  }


  initCreateChatGroupViewModel() async{
    loading(true);
    localUser(await LocalStorageUser.getUserData());
    receiverUsers.add(localUser.value!);
    loading(false);
  }


  Rx<ChatModel> chatData = Rx(ChatModel());

  Future<void> createChat(userIds) async {
    ChatModel chat =
    await FirestoreChat().createChat(localUser.value!.id!, receiverUsers, userIds);
    chatData(chat);
  }


  createGroup(String? value) async {
    String messageText = '';

    if (value != null) {
      messageText = value;
    }else {
      messageText = messageTextEditingController.text.toString();
    }

    if(messageText.isNotEmpty) {
      if(receiverUsers.length > 2) {

        AppDialogs.upload("Creating new group..");
        sending(true);

        List<String> userIds = receiverUsers.map((e) => e.id??'').toList();

        await createChat(userIds);

        MessageModel message = MessageModel(
          senderId: localUser.value!.id!,
          text: messageText,
          imageUrls: [],
          giphyUrl: '',
          timeCreated: Timestamp.now(),
          isLiked: false,
        );

        FirestoreChat()
            .sendGroupChatMessage(chatData.value, message, receiverUsers);

        sending(false);

        // reset values
        messageTextEditingController.clear();

        Get.close(1);
        Get.snackbar("Info...", "Group created successfully!", snackPosition: SnackPosition.BOTTOM);

      }else {
        Get.snackbar("Info...", "Select attlist 2 group member!", snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar("Info...", "Message cannot be empty!", snackPosition: SnackPosition.BOTTOM);
    }

  }
}

class CreateChatGroupView extends StatelessWidget {
  final String currentUserId;

  const CreateChatGroupView({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: SafeArea(
        child: GetBuilder<CreateChatGroupViewModel>(
            init: Get.put(CreateChatGroupViewModel()),
            builder: (controller) {
              return Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  titleSpacing: 0,
                  leading: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      FontAwesomeIcons.angleLeft,
                    ),
                  ),
                  title: const Text("Create Message"),
                  actions: [
                    Padding(
                      padding: REdgeInsets.all(15),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0.0),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColors.appColorBlue),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                        ),
                        child: Text(
                          'Create',
                          style: Get.textTheme.bodyText2!
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () => controller.createGroup(null),
                      ),
                    ),
                  ],
                ),
                body: Padding(
                  padding: REdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller.messageTextEditingController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) => controller.createGroup(value),
                        decoration: const InputDecoration(
                            hintText: "Type message",
                            labelText: "Message",
                            prefixIcon: Icon(
                              FontAwesomeIcons.envelope,
                            )),
                        style: Get.textTheme.bodyText2,
                        keyboardType: TextInputType.text,
                      ),
                      Padding(
                        padding: REdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          children: [
                            Text(
                              'TO:',
                              style: Get.textTheme.titleLarge,
                            ),
                            SizedBox(width: 8.w,),
                            Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Obx(()=>Row(
                                    children: controller.receiverUsers.reversed
                                        .map((e) => peopleChip(e, () {
                                        Get.find<ChatGroupArtistCardViewModel>(tag: e.id).removeArtist(e);
                                    }, controller))
                                        .toList(),
                                  )),
                                ))
                          ],
                        ),
                      ),
                      Obx(()=> Text(
                        'Total Members: (${controller.receiverUsers.length})',
                        style: Get.textTheme.titleLarge,
                      )),

                      const Divider(
                        height: 15,
                        thickness: 1,
                      ),

                      Expanded(
                        child: PaginateFirestore(
                          itemBuilder: (context, documentSnapshots, index) {
                            String artistId = documentSnapshots[index].id;

                            return ChatGroupArtistCardWidget(
                              controller: Get.put(
                                  ChatGroupArtistCardViewModel(artistId: artistId),
                                  tag: artistId),
                            );
                          },
                          query: FirestoreQueries.artistsFollowingQuery(
                              currentUserId),
                          itemBuilderType: PaginateBuilderType.listView,
                          isLive: false,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }



  Widget peopleChip(UserModel user, VoidCallback onTap, CreateChatGroupViewModel controller) {
    return Container(
      padding: REdgeInsets.all(8),
      margin: REdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(Get.isDarkMode),
        borderRadius: BorderRadius.circular(23.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 30.r,
            width: 30.r,
            margin: REdgeInsets.only(right: 8),
            decoration: BoxDecoration(
                color: AppColors.disabledButtonColor,
                borderRadius: BorderRadius.circular(15.r),
                border:
                Border.all(color: AppColors.disabledButtonColor, width: 2),
                image: DecorationImage(
                    image: user.imageUrl!.isNotEmpty
                        ? NetworkImage(user.imageUrl!)
                        : const AssetImage(AppImages.guestUserLogo)
                    as ImageProvider)),
          ),
          Text(
            user.name!,
          ),
          if(user.id != controller.localUser.value!.id)
          GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: REdgeInsets.only(left: 15),
                child: const Icon(
                  FontAwesomeIcons.times,
                  color: AppColors.disabledButtonColor,
                ),
              ))
        ],
      ),
    );
  }

}
