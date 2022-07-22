import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_images.dart';
import 'package:inkistry/model/user_model.dart';


class BlankStoryCircleWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback goToCameraScreen;
  final double size;
  final bool showUserName;

  const BlankStoryCircleWidget(
      {Key? key,
    required this.user,
    required this.goToCameraScreen,
    this.size = 60,
    this.showUserName = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;

    return Container(
      width: size.w + 10.w,
      margin: REdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                margin: REdgeInsets.all(5.0),
                height: size.h,
                width: size.h,
                padding: REdgeInsets.all(2),
                decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 3.0, color: Colors.grey),
                      ),
                child: GestureDetector(
                  onTap: goToCameraScreen,
                  child: ClipOval(
                    child: user.imageUrl != null ? SvgPicture.asset(
                      AppImages.storyPlaceHolder,
                      height: size.h,
                      width: size.h,
                      fit: BoxFit.cover,
                    ):Image(
                      image: CachedNetworkImageProvider(user.imageUrl!),
                      height: size.h,
                      width: size.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
                Positioned(
                  bottom: 5,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                        size: size == 60 ? 21 : 30,
                      ),
                    ),
                  ),
                )
            ],
          ),
          if (showUserName)
            const Expanded(
              child: Text(
                'You',
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
              ),
            )
        ],
      ),
    );
  }
}
