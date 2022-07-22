import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/app_colors.dart';
import '../../../model/chat_model.dart';
import '../../../model/user_model.dart';
import '../user/user_avatar_widget.dart';

class ChatUserWidget extends StatelessWidget {
  final ChatModel chat;
  final UserModel localUser;
  final VoidCallback onPressed;

  const ChatUserWidget(
      {Key? key,
      required this.chat,
      required this.localUser,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    final bool isRead = chat.readStatus[localUser.id!];
    final TextStyle readStyle = TextStyle(
        color: isRead
            ? AppColors.disabledButtonColor
            : AppColors.enabledButtonColor,
        fontWeight: isRead ? FontWeight.w400 : FontWeight.bold);

    List<UserModel> users = chat.memberInfo!;

    int receiverIndex = users.indexWhere((user) => user.id != localUser.id);

    bool isGroup = false;
    if (users.length > 3) {
      isGroup = true;
    }

    UserModel receiverUser = users[receiverIndex];
    users.removeWhere((user) => user.id == localUser.id);

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 7.5,
      ),
      decoration: BoxDecoration(
          color: AppColors.cardBackground(Get.isDarkMode),
          borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: !isGroup
            ? UserAvatarWidget(
                users: receiverUser,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    widthFactor: 1,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20.r,
                      child: CircleAvatar(
                        radius: 18.r,
                        backgroundImage: CachedNetworkImageProvider(
                            users[0].imageUrl!), // Provide your custom image
                      ),
                    ),
                  ),
                  Align(
                    widthFactor: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20.r,
                      child: CircleAvatar(
                        radius: 18.r,
                        backgroundImage: CachedNetworkImageProvider(
                            users[1].imageUrl!), // Provide your custom image
                      ),
                    ),
                  ),
                  Align(
                    widthFactor: 1,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20.r,
                      child: Center(
                        child: Text("${users.length - 2}+"),
                      ),
                    ),
                  )
                ],
              ),
        title: Text(isGroup ? "Chat Group" : receiverUser.name!,
            style: Get.textTheme.subtitle1!),
        subtitle: chat.recentSender!.isEmpty
            ? Text(
                'Chat Created',
                overflow: TextOverflow.ellipsis,
                style: readStyle,
              )
            : chat.recentMessage != null
                ? Text(
                    //'${chat.memberInfo![senderIndex].name} : ${chat.recentMessage}',
                    '${chat.recentSender == localUser.id ? 'You : ${chat.recentMessage}' : chat.recentMessage}',
                    overflow: TextOverflow.ellipsis,
                    style: readStyle,
                  )
                : Text(
                    //'${chat.memberInfo![senderIndex].name} : \nSent an attachment',
                    chat.recentSender == localUser.id
                        ? 'You : Sent an attachment'
                        : 'Sent an attachment',
                    overflow: TextOverflow.ellipsis,
                    style: readStyle,
                  ),
        trailing: Text(
          DateFormat('E, h:mm a').format(
            chat.recentTimestamp!.toDate(),
          ),
          style: Get.textTheme.bodyText1!.copyWith(fontSize: 12),
        ),
        onTap: onPressed,
      ),
    );
  }
}
