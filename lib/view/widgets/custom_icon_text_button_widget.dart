import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomIconTextButtonWidget extends StatelessWidget {
  final IconData iconData;
  final String text;
  final VoidCallback onPressed;

  const CustomIconTextButtonWidget(
      {Key? key,
      required this.iconData,
      required this.text,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Container(
      padding: REdgeInsets.symmetric(vertical: 5.h),
      height: 60.h,
      width: double.infinity,
      child: ElevatedButton.icon(
          icon: Container(
            margin: REdgeInsets.symmetric(vertical: 5.h),
            transform: Matrix4.translationValues(-15.0, 0.0, 0.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 2),
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              iconSize: 14,
              icon: Icon(iconData),
              onPressed: onPressed,
            ),
          ),
          onPressed: onPressed,
          label: Transform(
            transform: Matrix4.translationValues(-15.0, 0.0, 0.0),
            child: Text(
              text,
              style: Get.theme.textTheme.titleMedium,
            ),
          ),
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0.0),
          shape:
          MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
            alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
