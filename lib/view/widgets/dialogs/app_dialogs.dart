import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


abstract class AppDialogs {
  /// Stencils categories bottom sheet
  /// Select the stencil category from the category list
  static void upload(String title) {
    Get.dialog(
      Center(
        child: WillPopScope(
          onWillPop: () async => false,
          child: Container(
            padding: REdgeInsets.all(15.0),
            margin: REdgeInsets.all(40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              shape: BoxShape.rectangle,
              color: Colors.black.withOpacity(0.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5.0,
                  offset: Offset(5.0, 5.0),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    height: 20.r,
                    width: 20.r,
                    child: const CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(
                  width: 15.w,
                ),
                Flexible(
                  child: Text(
                    title,
                    style: Get.theme.textTheme.bodyText2!
                        .copyWith(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
