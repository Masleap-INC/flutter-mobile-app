import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_images.dart';
import 'package:inkistry/model/post_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../model/capture_type.dart';

class StencilCardWidget extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  const StencilCardWidget({Key? key, required this.post, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Container(
      margin: REdgeInsets.symmetric(vertical: 7.5, horizontal: 7.5),
      constraints: BoxConstraints(minHeight: 100.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            _stencilPhotoViewWidget(),
            _stencilCardIndicator(),
            _stencilTagIndicator()
          ],
        ),
      ),
    );
  }

  /// Grid photo view
  Widget _stencilPhotoViewWidget() {
    if (post.captureType == CaptureType.photo.name &&
        post.imageUrls!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          post.imageUrls![0],
          fit: BoxFit.cover,
        ),
      );
    }
    if (post.captureType == CaptureType.video.name) {
      return FutureBuilder<String>(
          future: _videoThumbnail(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Image.file(
                    File(snapshot.data!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          });
    }
    return const SizedBox.shrink();
  }

  /// Grid card multiple images and capture type indicator
  Widget _stencilCardIndicator() {
    IconData? icon;

    if (post.imageUrls!.length > 1) {
      icon = FontAwesomeIcons.solidClone;
    } else if (post.captureType == CaptureType.video.name) {
      icon = FontAwesomeIcons.play;
    }

    return Positioned.fill(
      child: Padding(
        padding: REdgeInsets.all(10),
        child: Align(
          alignment: Alignment.bottomRight,
          child: icon != null
              ? Icon(
                  icon,
                  size: 14.sp,
                  color: Colors.white,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Grid card tag indicator
  Widget _stencilTagIndicator() {
    return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (DateTime.now().difference(post.createdAt!.toDate()).inHours <
                  72)
                SvgPicture.asset(
                  AppImages.newTagIcon,
                  height: 24,
                ),
              if (post.isPremium!)
                const SizedBox(
                  width: 5,
                ),
              if (post.isPremium!)
                SvgPicture.asset(
                  AppImages.premiumTagIcon,
                  height: 24,
                )
            ],
          ),
        ));
  }

  Future<String> _videoThumbnail() async {
    return await VideoThumbnail.thumbnailFile(
          video: post.videoUrl!,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.WEBP,
          maxHeight: 64,
          quality: 100,
        ) ??
        '';
  }
}
