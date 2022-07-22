import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:inkistry/model/post_model.dart';
import 'package:inkistry/view/widgets/shimmer/app_shimmer.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/values/app_images.dart';
import '../../core/values/database_query.dart';
import '../../core/viewmodel/activity_viewmodel.dart';
import '../../core/viewmodel/home_viewmodel.dart';
import '../../core/viewmodel/post_card_viewmodel.dart';
import '../../core/viewmodel/stories_page_viewmodel.dart';
import '../../core/viewmodel/stories_viewmodel.dart';
import '../activity_view.dart';
import '../stories/stories_page_view.dart';
import '../widgets/post/post_card_widget.dart';
import '../widgets/stories/blank_story_circle_widget.dart';
import '../widgets/stories/story_circle_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    context.theme;
    return GetBuilder<HomeViewModel>(
        init: Get.find<HomeViewModel>(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              //titleSpacing: 0,
              title: SvgPicture.asset(
                AppImages.welcomeLogo,
                height: 40.h,
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    controller.isListViewType(true);
                  },
                  child: Padding(
                    padding: REdgeInsets.symmetric(horizontal: 8),
                    child: Obx(() => SvgPicture.asset(
                          AppImages.homePostListIcon,
                          height: 24,
                          color: controller.isListViewType.value
                              ? AppColors.enabledButtonColor
                              : AppColors.disabledButtonColor,
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    controller.isListViewType(false);
                  },
                  child: Padding(
                    padding: REdgeInsets.symmetric(horizontal: 8),
                    child: Obx(() => SvgPicture.asset(
                      AppImages.homePostGridIcon,
                          height: 24,
                          color: !controller.isListViewType.value
                              ? AppColors.enabledButtonColor
                              : AppColors.disabledButtonColor,
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(const ActivityView()),
                  child: Padding(
                    padding: REdgeInsets.only(left: 8, right: 15),
                    child: GetBuilder<ActivityViewModel>(
                        init: Get.find<ActivityViewModel>(),
                        builder: (activityViewModelController) {
                          return Obx(() => Badge(
                                shape: BadgeShape.circle,
                                badgeColor: AppColors.appBadgeColor,
                                position: BadgePosition.topEnd(top: 12, end: 2),
                                showBadge: activityViewModelController
                                    .haveNewActivity.value,
                                child: SvgPicture.asset(
                                  AppImages.homeNotificationBellIcon,
                                  height: 24,
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ));
                        }),
                  ),
                ),
              ],
            ),
            body: Obx(() => controller.loading.value
                ? SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        AppShimmerEffect.story(),
                        AppShimmerEffect.feedList()
                      ],
                    ),
                  )
                : Container(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: SingleChildScrollView(
                      padding: REdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Stories',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const ListViewStories(),
                          SizedBox(height: 10.h),
                          Obx(() => PaginateFirestore(
                                itemsPerPage: 10,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                onEmpty: const Center(
                                  child: Text("Empty"),
                                ),
                                itemBuilder:
                                    (context, documentSnapshots, index) {
                                  PostModel post = PostModel.fromDoc(
                                      documentSnapshots[index]);

                                  if (post.postType != null) {
                                    return Obx(
                                      () => PostCardWidget(
                                        controller: Get.put(
                                            PostCardViewModel(
                                              post: post,
                                              currentUser:
                                                  controller.currentUser,
                                            ),
                                            tag: post.id),
                                        isListViewType:
                                            controller.isListViewType.value,
                                        key: UniqueKey(),
                                      ),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                                query: FirestoreQueries.feedQuery(
                                    controller.currentUser.id!),
                                itemBuilderType: controller.isListViewType.value
                                    ? PaginateBuilderType.listView
                                    : PaginateBuilderType.gridView,
                                isLive: true,
                                key: UniqueKey(),
                              ))
                        ],
                      ),
                    ),
                  )),
          );
        });
  }
}

class ListViewStories extends StatelessWidget {
  const ListViewStories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewModel>(
      builder: (controller) => SizedBox(
        height: 90.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.storyResponseList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return BlankStoryCircleWidget(
                  user: controller.currentUser,
                  goToCameraScreen: () => controller.createANewStory());
            }

            return StoryCircleWidget(
              controller: Get.put(
                StoriesViewModel(
                  userStories: controller.storyResponseList[index - 1].stories!,
                  currentUser: controller.currentUser,
                  authorUser: controller.storyResponseList[index - 1].user!,
                  size: 60,
                ),
                tag: UniqueKey().toString(),
              ),
              onTap: (int seenStories) => Get.to(() => StoryPageView(
                      controller: Get.put(
                    StoriesPageViewModel(
                      userStories:
                          controller.storyResponseList[index - 1].stories!,
                      currentUser: controller.currentUser,
                      authorUser: controller.storyResponseList[index - 1].user!,
                      seenStories: seenStories,
                    ),
                    tag: controller.currentUser.id,
                  ))),
            );
          },
        ),
      ),
    );
  }
}
