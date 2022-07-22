import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:inkistry/main.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/viewmodel/camera_viewmodel.dart';
import '../../model/capture_type.dart';
import '../../model/post_type.dart';
import '../widgets/camera/camera_exposer_widget.dart';

class CameraView extends StatelessWidget {
  final PostType postType;
  final CaptureType captureType;

  const CameraView(
      {Key? key, required this.postType, required this.captureType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white24,
        // (Theme.of(context).brightness == Brightness.dark)
        //     ? colorPrimary
        //     : colorPrimaryDark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: GetBuilder<CameraViewModel>(
          init: Get.find<CameraViewModel>(),
          builder: (controller) {
            return Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: Container(
                    margin: REdgeInsets.only(left: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.r),
                            bottomLeft: Radius.circular(8.r))),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        FontAwesomeIcons.arrowLeft,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  titleSpacing: 0,
                  title: Container(
                      padding: REdgeInsets.fromLTRB(0, 9.5, 10, 9.5),
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8.r),
                              bottomRight: Radius.circular(8.r))),
                      child: Text(
                        captureType.name.capitalize!,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.black),
                      )),
                  actions: [
                    _exposerModeControlButton(controller),
                    if (captureType == CaptureType.video)
                      Obx(() => _audioModeControlButton(controller)),
                    Obx(() => _flashModeControlButton(controller)),
                  ],
                ),
                body: Stack(
                  children: <Widget>[
                    _cameraPreviewWidget(controller),
                    _exposureSliderWidget(controller),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                _cameraActionButton(controller),
                                _cameraSwitcherButton(controller),
                                _galleryMediaPickerButton(controller),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          }),
    );
  }

  Widget _exposerModeControlButton(CameraViewModel controller) {
    CameraController? cameraController = controller.camController.value;
    // ExposureMode? exposureMode = controller.camController.value?.value.exposureMode;
    //
    // ![ExposureMode.auto, ExposureMode.locked].contains(exposureMode);

    return Container(
      margin: REdgeInsets.fromLTRB(0.w, 5.h, 5.w, 5.h),
      decoration: BoxDecoration(
          color: Colors.white24, borderRadius: BorderRadius.circular(8.r)),
      child: IconButton(
          onPressed: cameraController != null
              ? () =>
                  controller.showExposure.value = !controller.showExposure.value
              : null,
          icon: const Icon(
            Icons.exposure,
            size: 24,
            color: Colors.black,
          )),
    );
  }

  Widget _audioModeControlButton(CameraViewModel controller) {
    return Container(
      margin: REdgeInsets.fromLTRB(0.w, 5.h, 5.w, 5.h),
      decoration: BoxDecoration(
          color: Colors.white24, borderRadius: BorderRadius.circular(8.r)),
      child: IconButton(
          onPressed: () => controller.onAudioModeButtonPressed(),
          icon: Icon(
            controller.enableAudio.value
                ? FontAwesomeIcons.volumeUp
                : FontAwesomeIcons.volumeMute,
            size: 24,
            color: Colors.black,
          )),
    );
  }

  Widget _flashModeControlButton(CameraViewModel controller) {
    CameraController? cameraController = controller.camController.value;
    FlashMode? flashMode = controller.camController.value?.value.flashMode;

    Widget _flashModeIcon() {
      switch (flashMode) {
        case FlashMode.off:
          return IconButton(
              onPressed: cameraController != null
                  ? () => controller.onSetFlashModeButtonPressed(FlashMode.auto)
                  : null,
              icon: const Icon(
                Icons.flash_off,
                size: 24,
                color: Colors.black,
              ));
        case FlashMode.auto:
          return IconButton(
              onPressed: cameraController != null
                  ? () =>
                      controller.onSetFlashModeButtonPressed(FlashMode.always)
                  : null,
              icon: const Icon(
                Icons.flash_auto,
                size: 24,
                color: Colors.black,
              ));
        case FlashMode.always:
          return IconButton(
              onPressed: cameraController != null
                  ? () =>
                      controller.onSetFlashModeButtonPressed(FlashMode.torch)
                  : null,
              icon: const Icon(
                Icons.flash_on,
                size: 24,
                color: Colors.orangeAccent,
              ));
        case FlashMode.torch:
          return IconButton(
              onPressed: cameraController != null
                  ? () => controller.onSetFlashModeButtonPressed(FlashMode.off)
                  : null,
              icon: const Icon(
                Icons.highlight,
                size: 24,
                color: Colors.orangeAccent,
              ));
        default:
          return const SizedBox.shrink();
      }
    }

    return Container(
      margin: REdgeInsets.fromLTRB(0.w, 5.h, 15.w, 5.h),
      decoration: BoxDecoration(
          color: Colors.white24, borderRadius: BorderRadius.circular(8.r)),
      child: _flashModeIcon(),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget(CameraViewModel controller) {
    double aspectRatio() {
      double height = ScreenUtil().screenHeight;
      double width = ScreenUtil().screenWidth;
      if (height != 0.0) {
        return width / height;
      }
      if (width > 0.0) {
        return double.infinity;
      }
      if (width < 0.0) {
        return double.negativeInfinity;
      }
      return 0.0;
    }

    final CameraController? cameraController = controller.camController.value;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return Positioned.fill(
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Icon(
            FontAwesomeIcons.camera,
            size: 80.sp,
          ),
        ),
      );
    } else {
      return Transform.scale(
        scale: 1 /
            (controller.camController.value!.value.aspectRatio * aspectRatio()),
        alignment: Alignment.topCenter,
        child: Listener(
          onPointerDown: (_) => controller.pointers++,
          onPointerUp: (_) => controller.pointers--,
          child: CameraPreview(
            controller.camController.value!,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: controller.handleScaleStart,
                onScaleUpdate: controller.handleScaleUpdate,
                onTapDown: (TapDownDetails details) =>
                    controller.onViewFinderTap(details, constraints),
              );
            }),
          ),
        ),
      );
    }
  }

  Widget _exposureSliderWidget(CameraViewModel controller) {
    return Positioned.fill(
      right: 10.w,
      child: Obx(() => IgnorePointer(
            ignoring: !controller.showExposure.value,
            child: AnimatedOpacity(
              opacity: controller.showExposure.value ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.centerRight,
                child: Obx(() => CameraExposerWidget(
                      key: UniqueKey(),
                      value: controller.currentExposureOffset.value,
                      min: controller.minAvailableExposureOffset,
                      max: controller.maxAvailableExposureOffset,
                      width: 48.w,
                      activeTrackColor: Colors.white54,
                      inactiveTrackColor: Colors.white24,
                      onChanged: controller.minAvailableExposureOffset ==
                              controller.maxAvailableExposureOffset
                          ? null
                          : controller.setExposureOffset,
                    )),
              ),
            ),
          )),
    );
  }

  Widget _galleryMediaPickerButton(CameraViewModel controller) {
    return Align(
        alignment: Alignment.centerLeft,
        child: CircleAvatar(
          backgroundColor: Colors.white24,
          radius: 25.r,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              FontAwesomeIcons.solidImages,
              size: 24,
            ),
            color: Colors.black,
            onPressed: () => controller.galleryImage(captureType),
          ),
        ));
  }

  Widget _cameraSwitcherButton(CameraViewModel controller) {
    return Align(
        alignment: Alignment.centerRight,
        child: CircleAvatar(
          backgroundColor: Colors.white24,
          radius: 25.r,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              FontAwesomeIcons.sync,
              size: 24,
            ),
            color: Colors.black,
            onPressed: () {
              if (camerasList.length > 1) {
                if (controller.camController.value!.description ==
                    camerasList[0]) {
                  controller.onNewCameraSelected(camerasList[1]);
                } else {
                  controller.onNewCameraSelected(camerasList[0]);
                }
              }
            },
          ),
        ));
  }

  Widget _cameraActionButton(CameraViewModel controller) {
    switch (captureType) {
      case CaptureType.photo:
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(45.r),
              onTap: () => controller.onTakePictureButtonPressed(),
              splashColor: Colors.black.withOpacity(0.5),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 45.r,
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  radius: 40.r,
                ),
              ),
            ),
          ),
        );
      case CaptureType.video:
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.circular(40.r),
                onTap: () {
                  if (controller.isVideoRecording.value) {
                    controller.onStopButtonPressed();
                  } else {
                    controller.onVideoRecordButtonPressed();
                  }
                },
                splashColor: Colors.black.withOpacity(0.5),
                child: Obx(() => CircularPercentIndicator(
                      radius: 45.r,
                      lineWidth: 5.0,
                      percent: controller.videoRecordingProgress.value,
                      center: CircleAvatar(
                        backgroundColor: Colors.white70,
                        radius: 40.r,
                        child: Icon(controller.isVideoRecording.value
                            ? Icons.stop
                            : Icons.play_arrow),
                      ),
                      backgroundColor: Colors.white24,
                      progressColor: controller.isVideoRecording.value
                          ? AppColors.enabledButtonColor.withOpacity(0.50)
                          : Colors.transparent,
                    ))),
          ),
        );
    }
  }
}
