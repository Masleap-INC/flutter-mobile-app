import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkistry/model/capture_type.dart';
import 'package:video_player/video_player.dart';

import '../../main.dart';

class CameraViewModel extends GetxController with WidgetsBindingObserver {
  //TickerProviderStateMixin

  Rxn<CameraController> camController = Rxn<CameraController>();

  //CameraController? camController;

  XFile? imageFile;
  XFile? videoFile;
  RxBool enableAudio = true.obs;
  double minAvailableExposureOffset = 0.0;
  double maxAvailableExposureOffset = 0.0;
  RxDouble currentExposureOffset = 0.0.obs;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int pointers = 0;

  RxBool showExposure = false.obs;

  late Timer _timer;
  RxBool isVideoRecording = false.obs;
  RxDouble videoRecordingProgress = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    //WidgetsBinding.instance?.addObserver(this);

    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final CameraController? cameraController = camController.value;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  // #enddocregion AppLifecycle

  // initialize the camera
  initCamera() {
    void onChanged(CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    }

    if (camerasList.isEmpty) {
      _ambiguate(SchedulerBinding.instance)?.addPostFrameCallback((_) async {
        showInSnackBar('No camera found.');
      });
      return const Text('None');
    } else {
      if (camerasList.isNotEmpty) {
        camController.value != null &&
                camController.value!.value.isRecordingVideo
            ? null
            : onChanged(camerasList[0]);
      }
    }
  }

  void handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (camController.value == null || pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await camController.value!.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String errorMessage) {
    Get.snackbar(
      'Camera message...',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (camController.value == null) {
      return;
    }

    final CameraController cameraController = camController.value!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = camController.value;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      camController.value = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio.value,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    camController.value = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      // if (mounted) {
      //   setState(() {});
      // }
      update();
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController
                    .getMinExposureOffset()
                    .then((double value) => minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((double value) => maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        case 'cameraPermission':
          // Android & web only
          showInSnackBar('Unknown permission error.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    // if (mounted) {
    //   setState(() {});
    // }
    update();
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      imageFile = file;

      if (file != null) {
        Get.back(result: file.path);
        //showInSnackBar('Picture saved to ${file.path}');
      }
      update();
    });
  }

  void onAudioModeButtonPressed() {
    enableAudio = RxBool(!enableAudio.value);
    if (camController.value != null) {
      onNewCameraSelected(camController.value!.description);
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (camController.value != null) {
        final CameraController cameraController = camController.value!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      update();
      //showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      // if (mounted) {
      //   setState(() {});
      // }
      update();
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      // if (mounted) {
      //   setState(() {});
      // }
      update();
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    int seconds = 30;
    videoRecordingProgress.value = 1.0;
    startVideoRecording().then((_) {
      isVideoRecording(true);
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        seconds--;
        videoRecordingProgress.value -= 1.0 / 30;

        if (seconds == 0) {
          onStopButtonPressed();
        }
      });
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      _timer.cancel();
      isVideoRecording(false);
      update();
      if (file != null) {
        videoFile = file;
        if (videoFile != null) {
          Get.back(result: videoFile!.path);
        }
      }
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = camController.value;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = camController.value;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (camController.value == null) {
      return;
    }

    try {
      await camController.value!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (camController.value == null) {
      return;
    }

    try {
      await camController.value!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (camController.value == null) {
      return;
    }

    currentExposureOffset.value = offset;
    update();
    try {
      offset = await camController.value!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (camController.value == null) {
      return;
    }

    try {
      await camController.value!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = camController.value;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void galleryImage(CaptureType captureType) async {
    if (captureType == CaptureType.photo) {
      final _pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (_pickedFile != null) {
        imageFile = XFile(_pickedFile.path);
        Get.back(result: imageFile!.path);
      }
    } else if (captureType == CaptureType.video) {
      final _pickedFile = await ImagePicker().pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 10));

      if (_pickedFile != null) {
        videoFile = XFile(_pickedFile.path);

        VideoPlayerController testLengthController =
            VideoPlayerController.file(File(videoFile!.path));
        await testLengthController.initialize();
        if (testLengthController.value.duration.inSeconds > 30) {
          videoFile = null;
          Get.snackbar("Warning...",
              "We only allow videos that are shorter than 30 seconds!",
              margin: REdgeInsets.only(bottom: 15),
              snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.back(result: videoFile!.path);
        }
        testLengthController.dispose();
      }
    }

    update();
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _logError(String code, String? message) {
    if (message != null) {
      if (kDebugMode) {
        print('Error: $code\nError Message: $message');
      }
    } else {
      if (kDebugMode) {
        print('Error: $code');
      }
    }
  }
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
T? _ambiguate<T>(T? value) => value;
