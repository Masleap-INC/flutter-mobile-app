import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:inkistry/model/user_model.dart';
import 'package:inkistry/view/widgets/user/user_avatar_widget.dart';

import '../../../../core/services/firestore_user.dart';
import '../../../../core/services/local_storage_user.dart';
import '../../../../core/viewmodel/profile_viewmodel.dart';
import '../../shimmer/app_shimmer.dart';
import '../user_badges_widget.dart';

class SearchArtistCardViewModel extends GetxController {
  final RxString artistId;
  final Rxn<UserModel> artist;

  SearchArtistCardViewModel({String? artistId, UserModel? artist})
      : artistId = RxString(artistId ?? ''),
        artist = Rxn(artist);

  RxBool isLoading = true.obs;
  RxnBool isFollowed = RxnBool();
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    _getArtist();
    super.onInit();
  }

  _getArtist() async {
    isLoading(true);

    if (artist.value == null && artistId.isNotEmpty) {
      DocumentSnapshot userDocSnapshot =
          await FirestoreUser().getUser(artistId.value);
      if (userDocSnapshot.exists) {
        artist.value = UserModel.fromDoc(userDocSnapshot);
        _initArtistFollowingStatus();
      }
    } else {
      _initArtistFollowingStatus();
    }

    isLoading(false);
  }

  /// Follow Artist section
  _initArtistFollowingStatus() async {
    isLoading(true);
    currentUser(await LocalStorageUser.getUserData());

    if (currentUser.value!.id != artist.value!.id!) {
      bool result = await FirestoreUser().getUserIsFollowed(
          artistId: artist.value!.id!, currentUserId: currentUser.value!.id!);
      isFollowed(result);
    }

    isLoading(false);
  }

  followThisArtist() async {
    FirestoreUser()
        .followUser(artistUser: artist.value!, currentUser: currentUser.value!);
    Get.find<ProfileViewModel>(tag: currentUser.value!.id!)
        .followingCount
        .value++;
    isFollowed(true);
  }

  unfollowThisArtist() async {
    FirestoreUser().unfollowUser(
        artistUser: artist.value!, currentUser: currentUser.value!);
    Get.find<ProfileViewModel>(tag: currentUser.value!.id!)
        .followingCount
        .value--;
    isFollowed(false);
  }
}

class SearchArtistCardWidget extends StatelessWidget {
  final SearchArtistCardViewModel controller;
  final VoidCallback? onTap;

  const SearchArtistCardWidget({Key? key, required this.controller, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;

    return Obx(() => controller.isLoading.value
        ? AppShimmerEffect.artistCard
        : controller.artist.value != null
            ? Container(
                margin: REdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(Get.isDarkMode),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  onTap: onTap,
                  leading: GestureDetector(
                    onTap: onTap,
                    child: UserAvatarWidget(
                      users: controller.artist.value!,
                    ),
                  ),
                  title: GestureDetector(
                    onTap: onTap,
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: controller.artist.value!.name!,
                            style: Theme.of(context).textTheme.subtitle1!,
                          ),
                          WidgetSpan(
                            child: UserBadgesWidget(
                                user: controller.artist.value!, size: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  subtitle: Text(
                    controller.artist.value!.username != null
                        ? '@' + controller.artist.value!.username!
                        : '@user',
                    style: Get.textTheme.bodyText2!.copyWith(
                        color: AppColors.disabledButtonColor,
                        fontWeight: FontWeight.normal),
                    softWrap: false,
                  ),
                  trailing: _trailingButton(),
                ))
            : const SizedBox.shrink());
  }

  Widget _trailingButton() {
    return Obx(
      () => controller.isFollowed.value != null
          ? (controller.isFollowed.value!
              ? OutlinedButton(
                  onPressed: () => controller.unfollowThisArtist(),
                  child: Text(
                    'Unfollow',
                    style: Get.textTheme.bodyText2!
                        .copyWith(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                )
              : ElevatedButton(
                  child: Text(
                    'Follow',
                    style: Get.textTheme.bodyText2!
                        .copyWith(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                  style: ButtonStyle(elevation: MaterialStateProperty.all(0.0)),
                  onPressed: () => controller.followThisArtist(),
                ))
          : const SizedBox.shrink(),
    );
  }
}
