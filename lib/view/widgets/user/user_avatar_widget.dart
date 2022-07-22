import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_images.dart';
import '../../../model/user_model.dart';


class UserAvatarWidget extends StatelessWidget {
  final UserModel users;
  final double? radius;
  const UserAvatarWidget({Key? key, required this.users, this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return CircleAvatar(
      backgroundColor: Colors.grey,
      backgroundImage: users.imageUrl!.isEmpty
          ? const AssetImage(AppImages.guestUserLogo)
          : CachedNetworkImageProvider(
        users.imageUrl!,
      ) as ImageProvider,
      radius: radius,
    );
  }
}
