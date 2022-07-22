import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/viewmodel/post_card_viewmodel.dart';
import '../../../model/capture_type.dart';
import '../../../model/post_type.dart';
import '../shimmer/app_shimmer.dart';
import '../user/user_avatar_widget.dart';
import '../user/user_badges_widget.dart';
import 'heart_anime_widget.dart';

class PostCardWidget extends StatelessWidget {
  final PostCardViewModel controller;
  final bool isListViewType;

  const PostCardWidget({
    Key? key,
    required this.controller,
    required this.isListViewType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return isListViewType ? listView() : gridView();
  }

  /// List view and its children---------------Started
  Widget listView() {
    return Container(
      margin: REdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: AppColors.cardBackground(Get.isDarkMode),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          /// Card header Widget
          controller.authorUser.value == null
              ? AppShimmerEffect.postCardHeader
              : _cardHeaderWidget(),

          // Need to do work
          if (controller.post.value.captureType == CaptureType.photo.name)
            _photoViewWidget(),

          if (controller.post.value.captureType == CaptureType.video.name)
            _videoViewWidget(),

          _actionBarWidget(),
          _captionViewWidget(),
          _taggedPeopleViewWidget(),
          _commentViewWidget(),
        ],
      ),
    );
  }

  /// Card header
  Widget _cardHeaderWidget() {
    return ListTile(
      leading: GestureDetector(
        onTap: () => controller.navigateToAuthorProfileView(),
        child: UserAvatarWidget(
          users: controller.authorUser.value!,
        ),
      ),
      title: GestureDetector(
        onTap: () => controller.navigateToAuthorProfileView(),
        child: RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            children: [
              TextSpan(
                text: controller.authorUser.value!.name!,
                style: Get.textTheme.subtitle1!,
              ),
              WidgetSpan(
                child: UserBadgesWidget(
                    user: controller.authorUser.value!, size: 15),
              ),
            ],
          ),
        ),
      ),
      subtitle: Text(
        timeago.format(controller.post.value.createdAt!.toDate()),
        style: Get.textTheme.bodyText2!
            .copyWith(color: AppColors.disabledButtonColor),
      ),
      trailing: GestureDetector(
        onTap: () => controller.openPostContextMenu(),
        child: Icon(
          Icons.more_vert,
          color: Get.theme.iconTheme.color,
        ),
      ),
    );
  }

  /// Post/Stencil photo view widgets
  Widget _photoViewWidget() {
    return GestureDetector(
      onTap: () => controller.navigateToPostDetailsView(),
      onDoubleTap: () => controller.likePost(),
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        child: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.143 / 1,
              child: Container(
                color: Colors.black,
                child: PageView.builder(
                    itemCount: controller.post.value.imageUrls!.length,
                    scrollDirection: Axis.horizontal,
                    physics: const PageScrollPhysics(),
                    onPageChanged: (index) {
                      controller.postImageCounter(index + 1);
                    },
                    itemBuilder: (context, index) {
                      return AspectRatio(
                        aspectRatio: 1.143 / 1,
                        child: PinchZoom(
                          child: CachedNetworkImage(
                            fadeInDuration: const Duration(milliseconds: 500),
                            imageUrl: controller.post.value.imageUrls![index],
                            fit: BoxFit.cover,
                          ),
                          resetDuration: const Duration(milliseconds: 100),
                          maxScale: 2.5,
                        ),
                      );
                    }),
              ),
            ),
            if (controller.post.value.imageUrls!.length > 1)
              Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF212730).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(50)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Obx(() => Text(
                          '${controller.postImageCounter.value}/${controller.post.value.imageUrls!.length}',
                        )),
                  )),
            _stencilButtonsWidgetList(),
            Obx(() => AspectRatio(
                  aspectRatio: 1.143 / 1,
                  child: controller.showHeartAnim.value
                      ? const HeartAnimeWidget(100.0)
                      : const SizedBox.shrink(),
                ))
          ],
        ),
      ),
    );
  }

  /// Post/Stencil video view widgets
  Widget _videoViewWidget() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => controller.navigateToPostDetailsView(),
      onDoubleTap: () => controller.likePost(),
      child: IgnorePointer(
        child: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.143 / 1,
              child: Container(
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: 1.143 / 1,
                  child:
                      Obx(() => controller.videoThumbnailPath.value.isNotEmpty
                          ? Image.file(
                              File(controller.videoThumbnailPath.value),
                              fit: BoxFit.cover,
                            )
                          : const SizedBox.shrink()),
                ),
              ),
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.black45,
                child: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => controller.navigateToPostDetailsView()),
              ),
            )),
            _stencilButtonsWidgetList(),
            Obx(() => AspectRatio(
                  aspectRatio: 1.143 / 1,
                  child: controller.showHeartAnim.value
                      ? const HeartAnimeWidget(100.0)
                      : const SizedBox.shrink(),
                ))
          ],
        ),
      ),
    );
  }

  /// Action bar widget
  Widget _actionBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //likes
          GestureDetector(
            onTap: () => controller.likePost(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() => !controller.isLikeLoading.value
                    ? Icon(
                        controller.isLiked.value
                            ? FontAwesomeIcons.solidHeart
                            : FontAwesomeIcons.heart,
                        size: 22,
                        color: controller.isLiked.value
                            ? AppColors.enabledButtonColor
                            : AppColors.disabledButtonColor,
                      )
                    : AppShimmerEffect.postCardLikeIcon),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Obx(() => Text(
                        NumberFormat.compact()
                            .format(controller.likeCount.value.toDouble()),
                        style: Get.textTheme.headline4!
                            .copyWith(color: AppColors.disabledButtonColor),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          //comments
          GestureDetector(
            onTap: () => controller.navigateToCommentsView(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.commentAlt,
                  size: 22,
                  color: AppColors.disabledButtonColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Obx(() => Text(
                        NumberFormat.compact()
                            .format(controller.commentCount.value.toDouble()),
                        style: Get.textTheme.headline4!
                            .copyWith(color: AppColors.disabledButtonColor),
                      )),
                ),
              ],
            ),
          ),
          const Spacer(),
          //bookmark
          GestureDetector(
            onTap: () => controller.bookPost(),
            child: Obx(() => !controller.isBookLoading.value
                ? Icon(
                    controller.isBooked.value
                        ? FontAwesomeIcons.solidBookmark
                        : FontAwesomeIcons.bookmark,
                    size: 22,
                    color: controller.isBooked.value
                        ? ((!Get.isDarkMode)
                            ? AppColors.enabledBookmarkButtonColor
                            : AppColors.disabledButtonColor)
                        : AppColors.disabledButtonColor,
                  )
                : AppShimmerEffect.postCardBookedIcon),
          ),
        ],
      ),
    );
  }

  /// Posts caption view widget
  Widget _captionViewWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ReadMoreText(
        controller.post.value.caption!,
        trimLines: 3,
        colorClickableText: AppColors.enabledButtonColor,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'more',
        trimExpandedText: 'less',
        moreStyle: Get.textTheme.bodyText1!
            .copyWith(color: AppColors.disabledButtonColor),
        style: Get.textTheme.bodyText1!,
      ),
    );
  }

  /// Tagged people view widget
  Widget _taggedPeopleViewWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      child: Wrap(
        children: controller.taggedUsersList
            .map((user) => GestureDetector(
                  onTap: () {
                    // navigate to user profile page
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      '@${user.username}',
                      style: Get.textTheme.bodyText2!
                          .copyWith(color: AppColors.disabledButtonColor),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// Comment view widget
  Widget _commentViewWidget() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () => controller.navigateToCommentsView(),
        child: Row(
          children: [
            if (controller.authorUser.value != null)
              UserAvatarWidget(
                users: controller.authorUser.value!,
                radius: 15,
              ),
            const SizedBox(
              width: 15.0,
            ),
            Text(
              'Add a comment...',
              style: Get.textTheme.bodyText1!,
            )
          ],
        ),
      ),
    );
  }

  /// Stencils Buttons Widget List
  Widget _stencilButtonsWidgetList() {
    return controller.post.value.postType == PostType.stencil.name
        ? Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stencilButtonsWidget(
                    icon: FontAwesomeIcons.dharmachakra,
                    text: "Stencil",
                  ),
                  const Spacer(),
                  _stencilButtonsWidget(
                      text: "Try now", onTap: () => controller.stencilTryNow()),
                ],
              ),
            ))
        : const SizedBox.shrink();
  }

  /// Stencil Buttons Widget
  Widget _stencilButtonsWidget(
      {IconData? icon, required String text, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF212730).withOpacity(0.7),
            borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 12,
              ),
            if (icon != null)
              const SizedBox(
                width: 5,
              ),
            Text(
              text,
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------------------------------------------------------------Ended

  /// Grid view and its children---------------Started
  Widget gridView() {
    return Container(
      padding: REdgeInsets.symmetric(vertical: 7.5, horizontal: 7.5),
      constraints: BoxConstraints(minHeight: 100.h),
      child: GestureDetector(
        onDoubleTap: () => controller.likePost(),
        onTap: () => controller.navigateToPostDetailsView(),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            _gridPhotoViewWidget(),
            _gridCardIndicator(),
            Obx(() => controller.showHeartAnim.value
                ? const HeartAnimeWidget(50.0)
                : const SizedBox.shrink()),
            _gridViewActionBarWidget(),
          ],
        ),
      ),
    );
  }

  /// Grid photo view
  Widget _gridPhotoViewWidget() {
    if (controller.post.value.captureType == CaptureType.photo.name &&
        controller.post.value.imageUrls!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          controller.post.value.imageUrls![0],
          fit: BoxFit.cover,
        ),
      );
    }
    if (controller.post.value.captureType == CaptureType.video.name) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Obx(() => controller.videoThumbnailPath.value.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                child: Image.file(
                  File(controller.videoThumbnailPath.value),
                  fit: BoxFit.cover,
                ),
              )
            : const SizedBox.shrink()),
      );
    }
    return const SizedBox.shrink();
  }

  /// Grid card multiple images and capture type indicator
  Widget _gridCardIndicator() {
    IconData? icon;

    if (controller.post.value.imageUrls!.length > 1) {
      icon = FontAwesomeIcons.solidClone;
    } else if (controller.post.value.captureType == CaptureType.video.name) {
      icon = FontAwesomeIcons.play;
    }

    return Positioned.fill(
      child: Padding(
        padding: REdgeInsets.symmetric(vertical: 10, horizontal: 13),
        child: Align(
          alignment: Alignment.topRight,
          child: icon != null
              ? Icon(
                  icon,
                  size: 14.sp,
                  color: Colors.white,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Grid view action bar widget
  Widget _gridViewActionBarWidget() {
    return Positioned.fill(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.01),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.5),
                ],
                stops: const [
                  0.0,
                  0.25,
                  0.5,
                  0.75,
                  1.0
                ]),
            borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10))),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => controller.likePost(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(() => !controller.isLikeLoading.value
                      ? Icon(
                          controller.isLiked.value
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          size: 18,
                          color: controller.isLiked.value
                              ? AppColors.enabledButtonColor
                              : Colors.white,
                        )
                      : AppShimmerEffect.postCardLikeIcon),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Obx(() => Text(
                          NumberFormat.compact()
                              .format(controller.likeCount.value),
                          style: Get.textTheme.titleMedium!
                              .copyWith(color: Colors.white),
                        )),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (controller.authorUser.value != null)
              UserAvatarWidget(
                users: controller.authorUser.value!,
                radius: 12,
              )
          ],
        ),
      ),
    ));
  }

  /// ---------------------------------------------------------------------Ended

}
