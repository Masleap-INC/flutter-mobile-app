import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:inkistry/model/user_model.dart';
import 'package:inkistry/view/widgets/user/user_avatar_widget.dart';

import '../../../../core/services/firestore_user.dart';
import '../../../chat/create_chat_group_view.dart';
import '../../shimmer/app_shimmer.dart';
import '../user_badges_widget.dart';

class ChatGroupArtistCardViewModel extends GetxController {
  final RxString artistId;
  final Rxn<UserModel> artist;

  ChatGroupArtistCardViewModel({String? artistId, UserModel? artist})
      : artistId = RxString(artistId ?? ''),
        artist = Rxn(artist);

  RxBool isLoading = true.obs;
  RxBool isAdded = false.obs;

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
        _initArtistTaggedStatus();
      }
    } else {
      _initArtistTaggedStatus();
    }

    isLoading(false);
  }

  RxList<UserModel> _getReceiverUsers() {
    return Get.find<CreateChatGroupViewModel>().receiverUsers;
  }


  /// Tag Artist section
  _initArtistTaggedStatus() async {
    var taggedUser = _getReceiverUsers();
    for (var i = 0; i < taggedUser.length; i++) {
      if (taggedUser[i].id == artist.value!.id!) {
        isAdded.value = true;
        break;
      }
    }
  }

  addThisArtist() async {
    _getReceiverUsers().add(artist.value!);
    isAdded.value = true;
  }

  removeThisArtist() async {
    _getReceiverUsers().removeAt(_getReceiverUsers().indexOf(artist.value!));
    isAdded.value = false;
  }

  removeArtist(UserModel user) async {
    _getReceiverUsers().removeAt(_getReceiverUsers().indexOf(user));
    isAdded.value = false;
  }

}

class ChatGroupArtistCardWidget extends StatelessWidget {
  final ChatGroupArtistCardViewModel controller;
  final VoidCallback? onTap;

  const ChatGroupArtistCardWidget({Key? key, required this.controller, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Obx(() => controller.isLoading.value
        ? AppShimmerEffect.artistCard
        : controller.artist.value != null
            ? Container(
                margin: REdgeInsets.fromLTRB(0, 7.5, 0, 7.5),
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
          () => controller.isAdded.value
          ? OutlinedButton(
        onPressed: ()=> controller.removeThisArtist(),
        child: Text(
          'Remove',
          style: Get.textTheme.bodyText2!
              .copyWith(fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
          softWrap: false,
        ),
      )
          : ElevatedButton(
        child: Text(
          'Add',
          style: Get.textTheme.bodyText2!
              .copyWith(fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
          softWrap: false,
        ),
        style: ButtonStyle(elevation: MaterialStateProperty.all(0.0)),
        onPressed: ()=> controller.addThisArtist(),
      ),
    );
  }
}
