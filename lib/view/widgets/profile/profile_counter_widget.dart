import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/app_colors.dart';

class ProfileCounterWidget extends StatelessWidget {
  final String title;
  final int value;
  final VoidCallback? onTap;
  const ProfileCounterWidget({Key? key, required this.title, required this.value, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: REdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(Get.isDarkMode),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              Padding(
                padding: REdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(
                  NumberFormat.compact().format(value),
                  style: Get.textTheme.headline4!.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: REdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  title,
                  style: Get.textTheme.bodyText2!.copyWith(
                    color: AppColors.disabledButtonColor
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
