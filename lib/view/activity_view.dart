import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/services/firestore_user.dart';
import 'package:inkistry/core/viewmodel/activity_viewmodel.dart';
import 'package:inkistry/model/activity_model.dart';
import 'package:inkistry/model/user_model.dart';
import 'package:inkistry/view/widgets/user/user_avatar_widget.dart';
import 'package:inkistry/view/widgets/user/user_badges_widget.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../core/values/app_colors.dart';
import '../core/values/database_query.dart';
import '../core/values/system_overlay.dart';

class ActivityView extends StatelessWidget {
  const ActivityView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                FontAwesomeIcons.angleLeft,
              ),
            ),
            title: const Text("Activity"),
          ),
          body: SafeArea(
            child: GetBuilder<ActivityViewModel>(
                init: Get.find<ActivityViewModel>(),
                builder: (controller) {
                  return PaginateFirestore(
                    itemBuilder: (context, documentSnapshots, index) {
                      var activity =
                          ActivityModel.fromDoc(documentSnapshots[index]);

                      if (activity.isMessageEvent == true ||
                          activity.isLikeMessageEvent == true) {
                        return const SizedBox.shrink();
                      }

                      controller.markActivityAsRead();

                      return _buildActivity(activity);
                    },
                    query: FirestoreQueries.activitiesQuery(
                        controller.currentUser!.id!),
                    itemBuilderType: PaginateBuilderType.listView,
                    isLive: false,
                    key: UniqueKey(),
                  );
                }),
          ),
        ),
      ),
    );
  }

  /// Activity card
  _buildActivity(ActivityModel activity) {
    return FutureBuilder(
      future: FirestoreUser().getUser(activity.fromUserId!),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        UserModel user = UserModel.fromDoc(snapshot.data);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
          decoration: BoxDecoration(
              color: AppColors.cardBackground(Get.isDarkMode),
              borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: UserAvatarWidget(
              users: user,
              radius: 25,
            ),
            title: activity.isFollowEvent == true
                ? Wrap(
                    children: <Widget>[
                      Text('${user.name}',
                          style: Theme.of(context).textTheme.bodyText2),
                      UserBadgesWidget(
                          user: user, size: 15, secondSizedBox: false),
                      Text(
                        'started following you',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  )
                : activity.isCommentEvent == true
                    ? Wrap(
                        children: <Widget>[
                          Text('${user.name}',
                              style: Theme.of(context).textTheme.bodyText2),
                          UserBadgesWidget(
                              user: user, size: 15, secondSizedBox: false),
                          Text(
                            'commented: "${activity.comment}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      )
                    : Wrap(
                        children: <Widget>[
                          Text('${user.name}',
                              style: Theme.of(context).textTheme.bodyText2),
                          UserBadgesWidget(
                              user: user, size: 15, secondSizedBox: false),
                          Text(
                            'liked your post: "${activity.comment}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
            subtitle: Text(
              timeago.format(activity.timestamp!.toDate()),
              style: Theme.of(context).textTheme.bodyText2,
            ),
            trailing: activity.postImageUrl == null
                ? const SizedBox.shrink()
                : CachedNetworkImage(
                    imageUrl: activity.postImageUrl!,
                    fadeInDuration: const Duration(milliseconds: 500),
                    height: 40.0,
                    width: 40.0,
                    fit: BoxFit.cover,
                  ),
            onTap: activity.isFollowEvent!
                ? () {
                    // Get.to(() => ArtistProfilePage(currentUser: user));
                  }
                : () async {
                    // Post post = await DatabaseService.getUserPost(
                    //   user.id!,
                    //   activity.postId!,
                    // );

                    // Get.to(() => CommentsPage(
                    //       postStatus: PostStatus.feedPost,
                    //       post: post,
                    //       likeCount: 0,
                    //       author: currentUser,
                    //     ));
                  },
          ),
        );
      },
    );
  }
}
