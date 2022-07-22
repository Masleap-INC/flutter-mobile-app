import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_images.dart';
import '../../../core/viewmodel/stories_viewmodel.dart';


class StoryCircleWidget extends StatelessWidget  {

  final StoriesViewModel controller;
  final Function(int) onTap;

  const StoryCircleWidget({Key? key,
    required this.controller,
    required this.onTap,
  }) :  super(key: key);


  @override
  Widget build(BuildContext context) {
    context.theme;
    return Container(
      width: controller.size.value.w + 10.w,
      margin: REdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(()=>Container(
            margin: REdgeInsets.all(5.0),
            height: controller.size.value.h,
            width: controller.size.value.h,
            padding: REdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 3.0, color: controller.circleColor.value),
            ),
            child: GestureDetector(
              onTap: ()=> onTap(controller.seenStories),
              child: ClipOval(
                child: controller.authorUser.value.imageUrl == null ? SvgPicture.asset(
                  AppImages.storyPlaceHolder,
                  height: controller.size.value.h,
                  width: controller.size.value.h,
                  fit: BoxFit.cover,
                ):Image(
                  image: CachedNetworkImageProvider(controller.authorUser.value.imageUrl!),
                  height: controller.size.value.h,
                  width: controller.size.value.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )),
          if (controller.showUserName.value)
            Expanded(
              child: Text(
                controller.authorUser.value.name!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
              ),
            )
        ],
      ),
    );
  }
}
