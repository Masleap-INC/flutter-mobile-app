import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/services/firestore_user.dart';
import '../../core/values/database_query.dart';
import '../../core/viewmodel/direct_message_viewmodel.dart';
import '../../model/chat_model.dart';
import '../../model/user_model.dart';
import '../widgets/chat/chat_user_widget.dart';
import '../widgets/shimmer/app_shimmer.dart';
import 'direct_messaging_view.dart';

class ChatRequestsTab extends StatelessWidget {
  final UserModel localUser;

  const ChatRequestsTab({Key? key, required this.localUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return PaginateFirestore(
      itemsPerPage: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: REdgeInsets.all(15),
      onEmpty: SizedBox(
        height: Get.size.height - 270,
        child: const Center(
          child: Text("No Chat available"),
        ),
      ),
      itemBuilder: (context, documentSnapshots, index) {
        ChatModel chatData = ChatModel.fromDoc(documentSnapshots[index]);

        Map<String, dynamic> readStatus = chatData.readStatus;

        if (readStatus[localUser.id] == true) {
          return const SizedBox.shrink();
        }

        List<dynamic> memberIds = chatData.memberIds!;
        //memberIds.remove(localUser.id);

        List<UserModel> membersInfo = [];

        return FutureBuilder(
          future: FirestoreUser().getUsers(memberIds),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Transform.translate(
                  offset: const Offset(-10, 0),
                  child: AppShimmerEffect.artistCard);
            }

            List<UserModel> receiverUsers = snapshot.data;
            membersInfo.addAll(receiverUsers);

            ChatModel chatWithUserInfo = ChatModel(
              id: chatData.id,
              memberIds: chatData.memberIds,
              memberInfo: membersInfo,
              readStatus: chatData.readStatus,
              recentMessage: chatData.recentMessage,
              recentSender: chatData.recentSender,
              recentTimestamp: chatData.recentTimestamp,
            );

            return ChatUserWidget(
              chat: chatWithUserInfo,
              localUser: localUser,
              onPressed: () {
                Get.to(() => DirectMessageView(
                  controller: Get.put(
                      DirectMessageViewModel(
                          localUser: localUser,
                          receiverUsers: receiverUsers),
                      tag: UniqueKey().toString()),
                ));
              },
              key: UniqueKey(),
            );

          },
        );
      },
      query: FirestoreQueries.chatRequestQuery(localUser.id!),
      itemBuilderType: PaginateBuilderType.listView,
      isLive: true,
    );
  }
}
