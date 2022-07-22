import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkistry/model/post_history_type.dart';
import 'package:intl/intl.dart';

import '../../../core/values/app_colors.dart';
import '../../../model/post_history_model.dart';

class PostHistoryCardWidget extends StatelessWidget {
  final PostHistoryModel history;
  final PostHistoryType type;
  final VoidCallback onTap;
  const PostHistoryCardWidget({Key? key, required this.history, required this.type, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7.5),
      decoration: BoxDecoration(
          color: AppColors.cardBackground(Get.isDarkMode),
          borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: CachedNetworkImageProvider(
            history.imageUrl!,
          ),
        ),
        title: Text(
          history.caption!,
          style: Get.textTheme.titleMedium!,
        ),
        subtitle: Text(
          '${type.name.capitalize} ${DateFormat.yMMMMd().format(DateTime.parse(history.createdAt!.toDate().toString()))}',
          style: Theme.of(context).textTheme.bodyText2!.copyWith(),
        ),
        trailing: GestureDetector(
          onTap: onTap,
          child: Icon(
            Icons.more_vert,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }
}
