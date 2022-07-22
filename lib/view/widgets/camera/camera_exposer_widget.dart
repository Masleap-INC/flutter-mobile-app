import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CameraExposerWidget extends StatelessWidget {
  const CameraExposerWidget({
    Key? key,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.value,
    this.activeTrackColor,
    this.inactiveTrackColor,
    required this.width,
  }) : super(key: key);
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final double value;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final double width;
  @override
  Widget build(BuildContext context) {
    context.theme;
    return Container(
      width: width,
      padding: REdgeInsets.all(5),
      decoration: BoxDecoration(
          color: inactiveTrackColor,
          borderRadius: BorderRadius.circular(8.r)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: activeTrackColor,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.transparent,
                overlayColor: Colors.transparent,
                thumbSelector: (textDirection, values, tapValue, thumbSize, trackSize, dx) => Thumb.start,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 0,
                  elevation: 0.0,
                ),
                trackHeight: width - 15.w,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 1),
                trackShape: CustomRoundedRectSliderTrackShape(Radius.circular(8.r)),
              ),
              child: Slider(
                onChanged: onChanged,
                min: min,
                max: max,
                value: value,
              ),
            ),
          ),
          Padding(
            padding: REdgeInsets.only(top: 5.h, bottom: 5.h),
            child: const Icon(
              FontAwesomeIcons.solidSun,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}

class CustomRoundedRectSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  final Radius trackRadius;
  const CustomRoundedRectSliderTrackShape(this.trackRadius);

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        double additionalActiveTrackHeight = 2,
      }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final ColorTween activeTrackColorTween =
    ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween =
    ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint leftTrackPaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint rightTrackPaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    var activeRect = RRect.fromLTRBAndCorners(
      trackRect.left,
      trackRect.top - (additionalActiveTrackHeight / 2),
      thumbCenter.dx,
      trackRect.bottom + (additionalActiveTrackHeight / 2),
      topLeft: trackRadius,
      bottomLeft: trackRadius,
    );
    var inActiveRect = RRect.fromLTRBAndCorners(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      topRight: trackRadius,
      bottomRight: trackRadius,
    );
    var percent = ((activeRect.width / (activeRect.width + inActiveRect.width)) * 100).toInt();
    if (percent > 99) {
      activeRect = RRect.fromLTRBAndCorners(
        trackRect.left,
        trackRect.top - (additionalActiveTrackHeight / 2),
        thumbCenter.dx,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
        topLeft: trackRadius,
        bottomLeft: trackRadius,
        bottomRight: trackRadius,
        topRight: trackRadius,
      );
    }

    if (percent < 1) {
      inActiveRect = RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
        topRight: trackRadius,
        bottomRight: trackRadius,
        bottomLeft: trackRadius,
        topLeft: trackRadius,
      );
    }
    context.canvas.drawRRect(
      activeRect,
      leftTrackPaint,
    );

    context.canvas.drawRRect(
      inActiveRect,
      rightTrackPaint,
    );

    //drawText(context.canvas, '%$percent', activeRect.center.dx, activeRect.center.dy, pi * 0.5, activeRect.width);
  }

  // void drawText(Canvas context, String name, double x, double y, double angleRotationInRadians, double height) {
  //   context.save();
  //   var span = TextSpan(style: TextStyle(color: Colors.white, fontSize: height >= 24.0 ? 24.0 : height), text: name);
  //   var tp = TextPainter(
  //     text: span,
  //     textAlign: TextAlign.center,
  //     textDirection: TextDirection.ltr,
  //   );
  //   tp.layout();
  //   context.translate((x + (tp.height * 0.5)), (y - (tp.width * 0.5)));
  //   context.rotate(angleRotationInRadians);
  //   tp.layout();
  //   tp.paint(context, const Offset(0.0, 0.0));
  //   context.restore();
  // }
}