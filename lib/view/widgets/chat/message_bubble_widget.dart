import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/model/message_model.dart';
import 'package:intl/intl.dart';
// import 'package:timeago/timeago.dart' as timeago;

import '../../../core/values/app_colors.dart';
import '../../../core/viewmodel/message_bubble_viewmodel.dart';
import '../../../model/user_model.dart';
import '../user/user_avatar_widget.dart';
// import '../user/user_badges_widget.dart';

class MessageBubbleWidget extends StatelessWidget {
  final MessageBubbleViewModel controller;

  const MessageBubbleWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Obx(() => controller.loading.value
        ? const SizedBox.shrink()
        : controller.senderIsMe.value!
            ? _senderMessageCardWidget(
                controller.localUser.value, controller.message.value)
            : _receiverMessageCardWidget(
                controller.receiverUser.value, controller.message.value));
  }

  Widget _receiverMessageCardWidget(UserModel author, MessageModel message) {
    return Padding(
      padding: REdgeInsets.only(right: Get.size.width / 10),
      child: ListTile(
        leading: GestureDetector(
          onTap: null,
          child: UserAvatarWidget(
            users: author,
          ),
        ),
        // title: GestureDetector(
        //   onTap: null,
        //   child: Padding(
        //     padding: REdgeInsets.only(top: 10),
        //     child: RichText(
        //       textAlign: TextAlign.start,
        //       text: TextSpan(
        //         children: [
        //           TextSpan(
        //             text: author.name,
        //             style: Get.textTheme.subtitle1!,
        //           ),
        //           WidgetSpan(
        //             child: UserBadgesWidget(user: author, size: 15),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.text!.isNotEmpty)
                      Container(
                        width: Get.size.width / 1.5 <= 200.w
                            ? Get.size.width / 1.5
                            : 200.w,
                        padding: REdgeInsets.all(10),
                        margin: REdgeInsets.only(top: 10, right: 0),
                        decoration: BoxDecoration(
                            color: AppColors.receiverMessageBubbleBackground(Get.isDarkMode),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15.r),
                              topLeft: Radius.circular(5.r),
                              bottomRight: Radius.circular(15.r),
                              bottomLeft: Radius.circular(15.r),
                            )),
                        child: Text(
                          message.text!,
                          style: Get.textTheme.bodyText2!,
                        ),
                      ),
                    if (message.imageUrls!.isNotEmpty)
                      Container(
                        width: Get.size.width / 2 <= 180.w
                            ? Get.size.width / 2
                            : 180.w,
                        height: Get.size.width / 2 <= 180.w
                            ? Get.size.width / 2
                            : 180.w,
                        margin: REdgeInsets.only(top: 10, right: 0),
                        decoration: BoxDecoration(
                          color: AppColors.disabledButtonColor,
                          image: DecorationImage(
                              image: NetworkImage(
                                message.imageUrls![0],
                              ),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Obx(() => controller.isLiked.value
                      ? const Icon(
                          FontAwesomeIcons.solidHeart,
                          color: AppColors.enabledButtonColor,
                        )
                      : const Icon(FontAwesomeIcons.heart)),
                  onPressed: ()=> controller.likeOrUnlikeMessage(),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              DateFormat('E, MMM d, yyyy, hh:mm a')
                  .format(message.timeCreated!.toDate()),
              // DateFormat.yMMMMEEEEd().format(message.timeCreated!.toDate()),
              // DateFormat.yMMMEd().format(message.timeCreated!.toDate()),
              // timeago.format(message.timeCreated!.toDate()),
              style: Get.textTheme.bodyText2!
                  .copyWith(color: AppColors.disabledButtonColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _senderMessageCardWidget(UserModel author, MessageModel message) {
    return Padding(
      padding: REdgeInsets.only(left: Get.size.width / 6, right: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() => controller.isLiked.value
                  ? const IconButton(
                      icon: Icon(
                        FontAwesomeIcons.solidHeart,
                        color: AppColors.enabledButtonColor,
                      ),
                      onPressed: null,
                    )
                  : const SizedBox.shrink()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.text!.isNotEmpty)
                    Container(
                      width: Get.size.width / 1.5 <= 200.w
                          ? Get.size.width / 1.5
                          : 200.w,
                      padding: REdgeInsets.all(10),
                      margin: REdgeInsets.only(top: 10, right: 0),
                      decoration: BoxDecoration(
                          color: AppColors.senderMessageBubbleBackground(Get.isDarkMode),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5.r),
                            topLeft: Radius.circular(15.r),
                            bottomRight: Radius.circular(15.r),
                            bottomLeft: Radius.circular(15.r),
                          )),
                      child: Text(
                        message.text!,
                        style: Get.textTheme.bodyText2!,
                      ),
                    ),
                  if (message.imageUrls!.isNotEmpty)
                    Container(
                      width:
                      Get.size.width / 2 <= 180.w ? Get.size.width / 2 : 180.w,
                      height:
                      Get.size.width / 2 <= 180.w ? Get.size.width / 2 : 180.w,
                      margin: REdgeInsets.only(top: 10, right: 0),
                      decoration: BoxDecoration(
                        color: AppColors.disabledButtonColor,
                        image: DecorationImage(
                            image: NetworkImage(
                              message.imageUrls![0],
                            ),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                ],
              )
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            DateFormat('E, MMM d, yyyy, hh:mm a')
                .format(message.timeCreated!.toDate()),
            // DateFormat.yMMMMEEEEd().format(message.timeCreated!.toDate()),
            // DateFormat.yMMMEd().format(message.timeCreated!.toDate()),
            // timeago.format(message.timeCreated!.toDate()),
            style: Get.textTheme.bodyText2!
                .copyWith(color: AppColors.disabledButtonColor),
          ),
        ],
      ),
    );
  }
}
