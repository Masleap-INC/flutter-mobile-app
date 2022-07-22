import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_images.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

import '../../core/values/app_colors.dart';
import '../../core/values/system_overlay.dart';
import '../../core/viewmodel/post_card_viewmodel.dart';
import '../../model/capture_type.dart';
import '../../model/post_type.dart';
import '../widgets/bottom_sheets/app_bottom_sheets.dart';

class EditPostView extends StatelessWidget {
  final String controllerTag;

  const EditPostView({
    Key? key,
    required this.controllerTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: GetBuilder<PostCardViewModel>(
          init: Get.find<PostCardViewModel>(tag: controllerTag),
          builder: (controller) {

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                titleSpacing: 0,
                leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    FontAwesomeIcons.angleLeft,
                  ),
                ),
                title: Text("Edit ${controller.post.value.postType!.capitalize!}"),
                actions: [
                  Padding(
                    padding: REdgeInsets.all(15),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0.0),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.appColorBlue),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: Get
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Colors.white),
                      ),
                      onPressed: () => controller.saveEditedPost(),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Wrap(
                  children: [
                    if (controller.post.value.captureType == CaptureType.photo.name)
                      _photoViewWidget(controller),

                    if (controller.post.value.captureType == CaptureType.video.name)
                      _videoViewWidget(controller),

                    if (controller.post.value.postType == PostType.stencil.name)
                    _stencilCategorySelectorWidget(controller),

                    _captionFieldWidget(controller),

                    Padding(
                      padding: REdgeInsets.symmetric(horizontal: 15),
                      child: Divider(height: 2.h, thickness: 2.h),
                    ),

                    Padding(
                      padding: REdgeInsets.all(15),
                      child: const Text("+ You can't update post without a caption."
                          "\n+ You can't change post's images."
                          "\n+ You can't change post's tagged users."
                          "\n+ You can't removed tagged users but you can freely edit the caption."),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  /// Post/Stencil photo view widgets
  Widget _photoViewWidget(PostCardViewModel controller) {
    return Container(
      width: double.infinity,
      // height: 200.0,
      margin: REdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.143 / 1,
            child: PageView.builder(
                itemCount: controller.post.value.imageUrls!.length,
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                onPageChanged: (index) {
                  controller.postImageCounter(index + 1);
                },
                itemBuilder: (context, index) {
                  return AspectRatio(
                    aspectRatio: 1.143 / 1,
                    child: PinchZoom(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15.r)),
                        child: CachedNetworkImage(
                          fadeInDuration: const Duration(milliseconds: 500),
                          imageUrl: controller.post.value.imageUrls![index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      resetDuration: const Duration(milliseconds: 100),
                      maxScale: 2.5,
                    ),
                  );
                }),
          ),
          if (controller.post.value.imageUrls!.length > 1)
            Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFF212730).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(50)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 15),
                  child: Obx(() => Text(
                    '${controller.postImageCounter.value}/${controller.post.value.imageUrls!.length}',
                  )),
                )),
        ],
      ),
    );
  }

  /// Post/Stencil video view widgets
  Widget _videoViewWidget(PostCardViewModel controller) {
    return Container(
      width: double.infinity,
      // height: 200.0,
      margin: REdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.143 / 1,
            child: AspectRatio(
              aspectRatio: 1.143 / 1,
              child:
              Obx(() => controller.videoThumbnailPath.value.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15.r)),
                    child: Image.file(
                File(controller.videoThumbnailPath.value),
                fit: BoxFit.cover,
              ),
                  )
                  : const SizedBox.shrink()),
            ),
          ),
          Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.black45,
                  child: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => controller.navigateToPostDetailsView()),
                ),
              )),
        ],
      ),
    );
  }


  /// Stencils category selection button
  Widget _stencilCategorySelectorWidget(PostCardViewModel controller) {
    return GestureDetector(
      onTap: () => AppBottomSheets.stencilCategorySheet(controller),
      child: Container(
        padding: REdgeInsets.symmetric(horizontal: 15, vertical: 15),
        margin: REdgeInsets.fromLTRB(15, 15, 15, 0),
        decoration: BoxDecoration(
            color: Get.theme.backgroundColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.disabledButtonColor)),
        child: Row(
          children: [
            const Text(
              'Category:',
            ),
            Expanded(
              child: Obx(() => Text(
                    controller.stencilsCategory.value,
                    textAlign: TextAlign.end,
                  )),
            ),
            Padding(
              padding: REdgeInsets.only(left: 10),
              child: const FaIcon(
                FontAwesomeIcons.caretDown,
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _captionFieldWidget(PostCardViewModel controller) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Container(
                height: 60.h,
                width: 60.h,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    color: AppColors.disabledButtonColor,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.black38, width: 2),
                    image: DecorationImage(
                        image: controller.currentUser.value.imageUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(
                          controller.currentUser.value.imageUrl!,
                        ) as ImageProvider
                            : const AssetImage(AppImages.guestUserLogo),
                        fit: BoxFit.cover)),
              )),
          Expanded(
            child: TextField(
              autofocus: false,
              onChanged: (value) async {

              },
              controller: controller.captionTextEditingController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Add a caption...',
              ),
              minLines: 1,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ),
        ],
      ),
    );
  }

}
