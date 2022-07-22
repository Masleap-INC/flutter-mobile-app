import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/services/firestore_user.dart';
import 'package:inkistry/core/values/system_overlay.dart';
import 'package:inkistry/core/viewmodel/post_card_viewmodel.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/values/app_colors.dart';
import '../../core/values/database_query.dart';
import '../../model/comment_model.dart';
import '../../model/user_model.dart';
import '../widgets/user/user_avatar_widget.dart';
import '../widgets/user/user_badges_widget.dart';

class CommentsView extends StatelessWidget {
  final String controllerTag;

  const CommentsView({
    Key? key,
    required this.controllerTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: SafeArea(
        child: GetBuilder<PostCardViewModel>(
            init: Get.find<PostCardViewModel>(tag: controllerTag),
            builder: (controller) {
              return Scaffold(
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
                  title: const Text("Comments"),
                ),
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PaginateFirestore(
                          itemBuilder: (context, documentSnapshots, index) {
                            var comments =
                                CommentModel.fromDoc(documentSnapshots[index]);

                            return _commentsCardWidget(
                                controller: controller, comments: comments);
                          },
                          query: FirestoreQueries.commentsQuery(
                              controller.post.value.id!),
                          itemBuilderType: PaginateBuilderType.listView,
                          isLive: true,
                          key: UniqueKey(),
                        ),
                      ),
                      Obx(() => controller.commentsImagePath.value.isNotEmpty
                          ? _pickedImageView(controller)
                          : const SizedBox.shrink()),
                      Obx(() => controller.commentsGiphyGifUrl.value.isNotEmpty
                          ? _giphyGifView(controller)
                          : const SizedBox.shrink()),
                      _commentTextField(controller),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  /// Comments card
  Widget _commentsCardWidget(
      {required PostCardViewModel controller, required CommentModel comments}) {
    return FutureBuilder<DocumentSnapshot>(
        future: FirestoreUser().getUser(comments.authorId!),
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            var author = UserModel.fromDoc(snapshot.data!);

            return ListTile(
              leading: GestureDetector(
                onTap: () => controller.navigateToAuthorProfileView(),
                child: UserAvatarWidget(
                  users: author,
                ),
              ),
              title: GestureDetector(
                onTap: () => controller.navigateToAuthorProfileView(),
                child: Padding(
                  padding: REdgeInsets.only(top: 10),
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: author.name,
                          style: Get.textTheme.subtitle1!,
                        ),
                        WidgetSpan(
                          child: UserBadgesWidget(
                              user: author, size: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeago.format(comments.createdAt!.toDate()),
                    style: Get.textTheme.bodyText2!
                        .copyWith(color: AppColors.disabledButtonColor),
                  ),
                  if(comments.comments!.isNotEmpty)
                    ReadMoreText(
                      comments.comments!,
                      trimLines: 5,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'more',
                      trimExpandedText: 'less',
                      style: Get.textTheme.bodyText2!,
                    ),
                  if(comments.imageUrl!.isNotEmpty)
                    Container(
                      width: Get.size.width/2 <= 180.w? Get.size.width/2: 180.w,
                      height: Get.size.width/2 <= 180.w? Get.size.width/2: 180.w,
                      margin: REdgeInsets.only(top: 10, right: 10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                              comments.imageUrl!,
                            ),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    )



                ],
              ),

            );
          }


          return const SizedBox.shrink();
        });
  }

  /// Build Comments textField
  Widget _commentTextField(PostCardViewModel controller) {
    return Padding(
        padding: REdgeInsets.all(15),
        child: TextField(
          controller: controller.commentsTextEditingController,
          onSubmitted: (value) {
            controller.commentsTextEditingController.text += '\n';
          },
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: "Add a comment..",
            labelText: "Comment",
            prefixIcon: Wrap(
              direction: Axis.horizontal,
              children: [
                IconButton(
                    padding: REdgeInsets.fromLTRB(12, 12, 8, 12),
                    constraints: const BoxConstraints(),
                    onPressed: () => controller.pickImagesUsingCamera(),
                    icon: Icon(
                      FontAwesomeIcons.camera,
                      color: Get.theme.textTheme.bodyText2!.color,
                    )),
                IconButton(
                    padding: REdgeInsets.fromLTRB(0, 12, 8, 12),
                    constraints: const BoxConstraints(),
                    onPressed: () => controller.getGiphyGif(),
                    icon: Icon(
                      FontAwesomeIcons.solidSmile,
                      size: 24,
                      color: Get.theme.textTheme.bodyText2!.color,
                    ))
              ],
            ),
            suffixIcon: IconButton(
                onPressed: () => controller.commentOnPost(),
                icon: Icon(
                  FontAwesomeIcons.solidPaperPlane,
                  color: Get.theme.textTheme.bodyText2!.color,
                )),
          ),
          style: Get.textTheme.bodyText2,
        ));
  }

  /// Image view
  Widget _pickedImageView(PostCardViewModel controller) {
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
                    File(controller.commentsImagePath.value),
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
                      controller.commentsImagePath('');
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// GiphyGif view
  Widget _giphyGifView(PostCardViewModel controller) {
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
                    controller.commentsGiphyGifUrl.value,
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
                      controller.commentsGiphyGifUrl('');
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
