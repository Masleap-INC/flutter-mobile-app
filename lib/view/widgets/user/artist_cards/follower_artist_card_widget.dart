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

class FollowerArtistCardViewModel extends GetxController {
  final RxString artistId;
  final Rxn<UserModel> artist;
  final Rx<UserModel> remoteUser;

  FollowerArtistCardViewModel(
      {String? artistId, UserModel? artist, required UserModel remoteUser})
      : artistId = RxString(artistId ?? ''),
        artist = Rxn(artist),
        remoteUser = Rx(remoteUser);

  RxBool isLoading = true.obs;
  RxnBool isFollowerRemoved = RxnBool();
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    _getArtist();
    super.onInit();
  }

  _getArtist() async {
    isLoading(true);
    currentUser(await LocalStorageUser.getUserData());

    if (artist.value == null && artistId.isNotEmpty) {
      DocumentSnapshot userDocSnapshot =
          await FirestoreUser().getUser(artistId.value);
      if (userDocSnapshot.exists) {
        artist.value = UserModel.fromDoc(userDocSnapshot);
      }
    }


    if (remoteUser.value.id! == currentUser.value!.id!) {
      isFollowerRemoved(false);
    }
    isLoading(false);
  }

  removeFollower() async {
    FirestoreUser().removeFollower(
        artistUser: artist.value!, currentUser: currentUser.value!);

    Get.find<ProfileViewModel>(tag: currentUser.value!.id!)
        .followerCount
        .value--;

    isFollowerRemoved(true);
  }
}

class FollowerArtistCardWidget extends StatelessWidget {
  final FollowerArtistCardViewModel controller;
  final VoidCallback? onTap;

  const FollowerArtistCardWidget(
      {Key? key, required this.controller, this.onTap})
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
      () => controller.isFollowerRemoved.value != null
          ? (controller.isFollowerRemoved.value!
              ? OutlinedButton(
                  onPressed: null,
                  child: Text(
                    'Removed',
                    style: Get.textTheme.bodyText2!
                        .copyWith(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                )
              : ElevatedButton(
                  child: Text(
                    'Remove',
                    style: Get.textTheme.bodyText2!
                        .copyWith(fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                  style: ButtonStyle(elevation: MaterialStateProperty.all(0.0)),
                  onPressed: () => controller.removeFollower(),
                ))
          : const SizedBox.shrink(),
    );
  }
}
