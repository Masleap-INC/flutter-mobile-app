import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';

class CustomTabWidget extends StatelessWidget {
  final String title;
  final IconData? iconData;
  final bool isActive;

  const CustomTabWidget(
      {Key? key,
      required this.title,
      this.iconData,
      required this.isActive})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 10),
      child: RichText(
        textAlign: TextAlign.center,
        softWrap: false,
        //overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            if(iconData != null)
            WidgetSpan(
                child: Icon(iconData,
                    size: 12,
                    color: isActive
                        ? AppColors.enabledButtonColor
                        : AppColors.disabledButtonColor),
                alignment: PlaceholderAlignment.middle),
            if(iconData != null)
            const WidgetSpan(
              child: SizedBox(
                width: 2,
              ),
            ),
            TextSpan(
                text: title,
                style: Get.textTheme.bodySmall!.copyWith(
                    color: isActive
                        ? AppColors.enabledButtonColor
                        : AppColors.disabledButtonColor)),
          ],
        ),
      ),
    );
  }
}
