import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/viewmodel/direct_message_viewmodel.dart';
import 'package:inkistry/view/profile/artists_posts_tab.dart';
import 'package:inkistry/view/widgets/bottom_sheets/app_bottom_sheets.dart';

import '../../core/values/app_colors.dart';
import '../../core/values/app_images.dart';
import '../../core/values/system_overlay.dart';
import '../../core/viewmodel/profile_viewmodel.dart';
import '../chat/direct_messaging_view.dart';
import '../widgets/profile/custom_tab_widget.dart';
import '../widgets/profile/profile_counter_widget.dart';
import '../widgets/profile/user_address_widget.dart';
import '../widgets/profile/user_name_widget.dart';
import 'artists_reviews_tab.dart';
import 'artists_stencils_tab.dart';

class ArtistsProfileView extends StatelessWidget {
  final ProfileViewModel controller;

  const ArtistsProfileView({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: Obx(() => controller.loading.value
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Get.theme.appBarTheme.backgroundColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleSpacing: 0,
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    FontAwesomeIcons.angleLeft,
                    color: Colors.white,
                  ),
                ),
                title: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
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
                                    ? controller.remoteUser.value!.coverImageUrl!
                                    : controller.remoteUser.value!.imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              if(controller.remoteUser.value!.coverImageUrl!.isEmpty)
                              ClipRRect(
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                                        color: Get.theme.scaffoldBackgroundColor,
                                        width: 5.0,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Get.theme.scaffoldBackgroundColor,
                                      backgroundImage: CachedNetworkImageProvider(
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
                                    value: controller.followerCount.value.toInt(),
                                    title: 'Followers',
                                    onTap: () => controller
                                        .navigateToFollowersAndFollowingPage(0),
                                  )),
                              Obx(() => ProfileCounterWidget(
                                  value: controller.stencilsCount.value.toInt(),
                                  title: 'Stencils',
                                  onTap: () {})),
                            ],
                          ),
                        ),
                        Container(
                          // width: double.infinity,
                          margin: REdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Get.to(() => DirectMessageView(
                                          controller: Get.put(
                                              DirectMessageViewModel(
                                                  localUser:
                                                      controller.localUser.value!,
                                                  receiverUsers: [
                                                    controller.remoteUser.value!,
                                                    controller.localUser.value!
                                                  ]),
                                              tag: UniqueKey().toString()),
                                        ));
                                  },
                                  child: Text(
                                    'Message',
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
                              SizedBox(
                                width: 5.w,
                              ),
                              Expanded(child: _followUnfollowButton())
                            ],
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
                                  title: 'Post',
                                  iconData: FontAwesomeIcons.clone,
                                  isActive: controller.tabController.index == 0),
                              CustomTabWidget(
                                  title: 'Stencils',
                                  iconData: FontAwesomeIcons.dharmachakra,
                                  isActive: controller.tabController.index == 1),
                              CustomTabWidget(
                                  title: 'Reviews',
                                  iconData: FontAwesomeIcons.thumbsUp,
                                  isActive: controller.tabController.index == 2),
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
                    ArtistsStencilsTab(
                      remoteUser: controller.remoteUser.value!,
                    ),
                    ArtistsReviewsTab(
                      remoteUser: controller.remoteUser.value!,
                    )
                  ],
                ),
              ),
            )),
    );
  }

  Widget _followUnfollowButton() {
    return Obx(
      () => controller.isFollowed.value != null
          ? (controller.isFollowed.value!
              ? OutlinedButton(
                  onPressed: () => controller.unfollowThisArtist(),
                  child: Text(
                    'Unfollow',
                    style: Get.textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.normal,
                        color: AppColors.appColorBlue),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:
                        REdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    side: const BorderSide(color: AppColors.appColorBlue),
                  ),
                )
              : ElevatedButton(
                  child: Text(
                    'Follow',
                    style: Get.textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.normal, color: Colors.white),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.appColorBlue,
                    elevation: 0.0,
                    padding:
                        REdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  onPressed: () => controller.followThisArtist(),
                ))
          : const SizedBox.shrink(),
    );
  }
}
