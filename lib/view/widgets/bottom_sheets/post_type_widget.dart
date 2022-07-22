import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/values/app_colors.dart';
import '../../../model/post_type.dart';


class PostTypeController extends GetxController {
  Rx<PostType> postType = PostType.post.obs;
}


class PostTypeWidget extends StatelessWidget {
  const PostTypeWidget({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return GetBuilder<PostTypeController>(
      init: Get.find<PostTypeController>(),
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          height: 60.h,
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.postType.value = PostType.post;
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      child: Obx(() => _buildOption(
                          context: context,
                          text: "Post",
                          isActive: controller.postType.value == PostType.post)),
                    ),
                  )),
              Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.postType.value = PostType.story;
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      child: Obx(() => _buildOption(
                          context: context,
                          text: "Story",
                          isActive: controller.postType.value == PostType.story)),
                    ),
                  )),
              Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.postType.value = PostType.stencil;
                    },
                    child: Obx(() => _buildOption(
                        context: context,
                        text: "Stencil",
                        isActive: controller.postType.value == PostType.stencil)),
                  )),
            ],
          ),
        );
      }
    );
  }

  Widget _buildOption({required BuildContext context, required String text, required bool isActive}) {
    context.theme;
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Column(
        children: [
          Text(
            text,
            style: isActive
                ? Theme.of(context).textTheme.bodyText2
                : Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: AppColors.disabledButtonColor),
          ),
          if (isActive) _buildCircle()
        ],
      ),
    );
  }


  Widget _buildCircle() {
    return CircleAvatar(
        radius: 3.r, backgroundColor: AppColors.enabledButtonColor);
  }
}
