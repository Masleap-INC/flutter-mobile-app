import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/view/profile/artists_bookmarks_tab.dart';
import 'package:inkistry/view/profile/artists_posts_tab.dart';
import 'package:inkistry/view/widgets/bottom_sheets/app_bottom_sheets.dart';

import '../../core/values/app_colors.dart';
import '../../core/values/app_images.dart';
import '../../core/viewmodel/profile_viewmodel.dart';
import '../profile/edit_profile_view.dart';
import '../widgets/profile/custom_tab_widget.dart';
import '../widgets/profile/profile_counter_widget.dart';
import '../widgets/profile/user_address_widget.dart';
import '../widgets/profile/user_name_widget.dart';

class ProfileView extends StatelessWidget {
  final ProfileViewModel controller;

  const ProfileView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return controller.loading.value
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SafeArea(
            child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Get.theme.appBarTheme.backgroundColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const WidgetSpan(
                          child: Icon(
                            FontAwesomeIcons.angleDown,
                            color: Colors.white,
                          ),
                          alignment: PlaceholderAlignment.middle),
                      TextSpan(
                          text: '@' + controller.remoteUser.value!.username!,
                          style: Get.textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      if (controller.remoteUser.value!.isVerified!)
                        WidgetSpan(
                            child: SvgPicture.asset(
                              AppImages.verifiedMarkIcon,
                              height: 18,
                            ),
                            alignment: PlaceholderAlignment.middle)
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        AppBottomSheets.userMenuSheet(
                            controller.remoteUser.value!.id!);
                      },
                      icon: const Icon(
                        FontAwesomeIcons.ellipsisH,
                        color: Colors.white,
                      )),
                  SizedBox(
                    width: 10.w,
                  )
                ],
              ),
              body: NestedScrollView(
                scrollDirection: Axis.vertical,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    //headerSilverBuilder only accepts slivers
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: controller.remoteUser.value!
                                        .coverImageUrl!.isNotEmpty
                                    ? controller
                                        .remoteUser.value!.coverImageUrl!
                                    : controller.remoteUser.value!.imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              if (controller
                                  .remoteUser.value!.coverImageUrl!.isEmpty)
                                ClipRRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppColors.linearGradient,
                                      ),
                                    ),
                                  ),
                                ),
                              Align(
                                child: Transform.translate(
                                  offset: const Offset(0, 90),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            Get.theme.scaffoldBackgroundColor,
                                        width: 5.0,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Get.theme.scaffoldBackgroundColor,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        controller.remoteUser.value!.imageUrl!,
                                      ),
                                      radius: 65.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 80.h),
                        UserNameWidget(user: controller.remoteUser.value!),
                        const UserAddressWidget(address: 'Toronto, Canada'),
                        if (controller.remoteUser.value!.bio!.isNotEmpty)
                          Text(
                            controller.remoteUser.value!.bio!,
                            style: Theme.of(context).textTheme.bodyText2!,
                          ),
                        Container(
                          padding: const EdgeInsets.all(11),
                          child: Row(
                            children: [
                              ProfileCounterWidget(
                                  value: controller.remoteUser.value!.postCount!
                                      .toInt(),
                                  title: 'Post'),
                              Obx(() => ProfileCounterWidget(
                                    value:
                                        controller.followerCount.value.toInt(),
                                    title: 'Followers',
                                    onTap: () => controller
                                        .navigateToFollowersAndFollowingPage(0),
                                  )),
                              Obx(() => ProfileCounterWidget(
                                    value:
                                        controller.followingCount.value.toInt(),
                                    title: 'Following',
                                    onTap: () => controller
                                        .navigateToFollowersAndFollowingPage(1),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          // width: double.infinity,
                          margin: REdgeInsets.symmetric(horizontal: 15),
                          child: OutlinedButton(
                            onPressed: () {
                              Get.to(EditProfileView(
                                controller: Get.put(
                                    ProfileViewModel(
                                        userId:
                                            controller.remoteUser.value!.id!),
                                    tag: controller.remoteUser.value!.id!),
                              ));
                            },
                            child: Text(
                              'Edit Profile',
                              style: Get.textTheme.bodyText2!.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.enabledButtonColor),
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: REdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30),
                              side: const BorderSide(
                                  color: AppColors.enabledButtonColor),
                            ),
                          ),
                        ),
                        Container(
                          margin: REdgeInsets.all(15),
                          padding: REdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground(Get.isDarkMode),
                            borderRadius: BorderRadius.circular(
                              25.r,
                            ),
                          ),
                          child: TabBar(
                            controller: controller.tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                25.r,
                              ),
                              color: Get.theme.appBarTheme.backgroundColor,
                            ),
                            labelColor: AppColors.enabledButtonColor,
                            unselectedLabelColor: AppColors.disabledButtonColor,
                            tabs: [
                              CustomTabWidget(
                                  title: 'My Post',
                                  iconData: FontAwesomeIcons.clone,
                                  isActive:
                                      controller.tabController.index == 0),
                              CustomTabWidget(
                                  title: 'Bookmarks',
                                  iconData: FontAwesomeIcons.bookmark,
                                  isActive:
                                      controller.tabController.index == 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: controller.tabController,
                  children: [
                    ArtistsPostTab(
                      currentUser: controller.localUser.value!,
                      remoteUser: controller.remoteUser.value!,
                    ),
                    ArtistsBookmarksTab(
                      remoteUser: controller.remoteUser.value!,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
