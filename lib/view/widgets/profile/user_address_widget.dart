import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';

class UserAddressWidget extends StatelessWidget {
  final String address;

  const UserAddressWidget({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          const WidgetSpan(
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.disabledButtonColor,
                size: 22,
              ),
              alignment: PlaceholderAlignment.bottom),
          const WidgetSpan(
              child: SizedBox(
                width: 4,
              ),
              alignment: PlaceholderAlignment.middle),
          TextSpan(
              text: address,
              style: Get.textTheme.titleLarge!.copyWith(
                fontSize: 18,
                color: AppColors.disabledButtonColor,
              )),
        ],
      ),
    );
  }
}
