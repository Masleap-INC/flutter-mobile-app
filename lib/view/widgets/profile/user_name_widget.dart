import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/values/app_images.dart';
import '../../../model/user_model.dart';


class UserNameWidget extends StatelessWidget {
  final UserModel user;
  const UserNameWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: user.name!.capitalize,
            style: Get.textTheme.titleLarge!.copyWith(
            )
          ),
          if (user.isVerified!)
            const WidgetSpan(
              child: SizedBox(
                width: 5,
              ),
                alignment: PlaceholderAlignment.middle
            ),
          if (user.isVerified!)
            WidgetSpan(
              child: SvgPicture.asset(
                AppImages.verifiedMarkIcon,
                height: 18,
              ),
                alignment: PlaceholderAlignment.middle
            )
        ],
      ),
    );
  }
}
