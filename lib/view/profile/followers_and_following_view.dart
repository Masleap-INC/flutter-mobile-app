import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/viewmodel/profile_viewmodel.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/services/local_storage_user.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/database_query.dart';
import '../../core/values/system_overlay.dart';
import '../../core/viewmodel/control_viewmodel.dart';
import '../../model/user_model.dart';
import '../widgets/profile/custom_tab_widget.dart';
import '../widgets/user/artist_cards/follower_artist_card_widget.dart';
import '../widgets/user/artist_cards/following_artist_card_widget.dart';

class FollowersAndFollowingViewModel extends GetxController
    with GetSingleTickerProviderStateMixin {
  Rx<UserModel> remoteUser;
  RxInt index;

  FollowersAndFollowingViewModel(
      {required UserModel remoteUser, required int index})
      : remoteUser = Rx(remoteUser),
        index = RxInt(index);

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
    tabController.animateTo(index.value);
    tabController.addListener(() {
      index(tabController.index);
    });
  }

  @override
  void dispose() {
    /// Disposing the tabController
    tabController.dispose();
    super.dispose();
  }
}

class FollowersAndFollowingView extends StatelessWidget {
  final FollowersAndFollowingViewModel controller;

  const FollowersAndFollowingView({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: Scaffold(
        backgroundColor: Get.theme.appBarTheme.backgroundColor,
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
          title: Text(
            controller.remoteUser.value.name!,
            style:
                Get.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: NestedScrollView(
          scrollDirection: Axis.vertical,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              //headerSilverBuilder only accepts slivers
              child: Column(
                children: [
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
                        Obx(()=>CustomTabWidget(
                            title:
                            'Followers (${Get.find<ProfileViewModel>(tag: controller.remoteUser.value.id!).followerCount})',
                            isActive: controller.tabController.index == 0)),
                        Obx(()=>CustomTabWidget(
                            title:
                            'Following (${Get.find<ProfileViewModel>(tag: controller.remoteUser.value.id!).followingCount})',
                            isActive: controller.tabController.index == 1)),
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
              _followersAndFollowingList(FirestoreQueries.artistsFollowersQuery(
                  controller.remoteUser.value.id!)),
              _followersAndFollowingList(FirestoreQueries.artistsFollowingQuery(
                  controller.remoteUser.value.id!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _followersAndFollowingList(Query query) {
    return PaginateFirestore(
      itemsPerPage: 10,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: REdgeInsets.symmetric(vertical: 15),
      onEmpty: SizedBox(
        height: Get.size.height - 270,
        child: const Center(
          child: Text("No artist available"),
        ),
      ),
      itemBuilder: (context, documentSnapshots, index) {
        var data = documentSnapshots[index].data() as Map<String, dynamic>;

        print("Length:---------------------- ${data.length}");

        String artistId = data['followedBy'];

        return Obx(() => controller.index.value == 0
            ? FollowerArtistCardWidget(
                controller: Get.put(
                    FollowerArtistCardViewModel(
                      remoteUser: controller.remoteUser.value,
                      artistId: artistId,
                    ),
                    tag: artistId),
                onTap: () async {
                  var currentUser = await LocalStorageUser.getUserData();
                  if (currentUser.id == artistId) {
                    Get.find<ControlViewModel>().changeCurrentScreen(4);
                  } else {
                    /// Navigate to the artist profile
                    ///
                  }
                },
              )
            : FollowingArtistCardWidget(
                controller: Get.put(
                    FollowingArtistCardViewModel(artistId: artistId),
                    tag: artistId),
                onTap: () async {
                  var currentUser = await LocalStorageUser.getUserData();
                  if (currentUser.id == artistId) {
                    Get.find<ControlViewModel>().changeCurrentScreen(4);
                  } else {
                    /// Navigate to the artist profile
                    ///
                  }
                },
              ));
      },
      query: query,
      itemBuilderType: PaginateBuilderType.listView,
      isLive: false,
      key: UniqueKey(),
    );
  }
}
