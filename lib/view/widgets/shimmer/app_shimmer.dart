import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

/// Copyright, 2022, by the authors. All rights reserved.

abstract class AppShimmerEffect {
  static Widget postCardHeader = PostShimmerEffect.cardHeader();
  static Widget postCardLikeIcon = PostShimmerEffect.cardLikeIcon();
  static Widget postCardBookedIcon = PostShimmerEffect.cardBookedIcon();
  static Widget artistCard = UserShimmerEffect.artistCard();

  static Widget story() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.3),
      highlightColor: Colors.grey.withOpacity(0.1),
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 15,
            width: 105,
            margin: const EdgeInsets.fromLTRB(15, 10, 0, 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFFe0f2f1)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: List.generate(
                  5,
                  (index) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.fromLTRB(15, 7.5, 15, 15),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFe0f2f1)),
                          ),
                          Container(
                            height: 10,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: const Color(0xFFe0f2f1)),
                          )
                        ],
                      )),
            ),
          ),
        ],
      ),
    );
  }

  static Widget feedList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.3),
      highlightColor: Colors.grey.withOpacity(0.1),
      enabled: true,
      child: Wrap(
        children: List.generate(
            4,
            (index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFe0f2f1)),
                    ),
                    Container(
                      width: double.infinity,
                      height: 15,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 150,
                      height: 15,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                )),
      ),
    );
  }
}

abstract class PostShimmerEffect {
  static Widget cardHeader() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        enabled: true,
        child: Padding(
          padding: REdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ScreenUtil().screenWidth / 3,
                      height: 12.sp,
                      margin: REdgeInsets.only(left: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Container(
                      width: double.infinity,
                      height: 10.sp,
                      margin: REdgeInsets.only(left: 15, right: 50),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    )
                  ],
                ),
              ),
              const Icon(Icons.more_vert)
            ],
          ),
        ));
  }

  static Widget cardLikeIcon() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        enabled: true,
        child: const Icon(
          FontAwesomeIcons.solidHeart,
          size: 22,
        ));
  }

  static Widget cardBookedIcon() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        enabled: true,
        child: const Icon(
          FontAwesomeIcons.solidBookmark,
          size: 22,
        ));
  }
}

abstract class UserShimmerEffect {
  static Widget artistCard() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        enabled: true,
        child: Padding(
          padding: REdgeInsets.symmetric(vertical: 15, horizontal: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ScreenUtil().screenWidth / 3,
                      height: 12.sp,
                      margin: REdgeInsets.only(left: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Container(
                      width: double.infinity,
                      height: 10.sp,
                      margin: REdgeInsets.only(left: 15, right: 50),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    )
                  ],
                ),
              ),
              const OutlinedButton(
                onPressed: null,
                child: Text('••••'),
              )
            ],
          ),
        ));
  }
}
