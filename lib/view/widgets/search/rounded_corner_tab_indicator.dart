import 'package:flutter/material.dart';

class RoundedCornerTabIndicator extends Decoration {
  final BoxPainter _painter;

  RoundedCornerTabIndicator({required Color color, double radius = 5, double height = 5})
      : _painter = _RoundedCornerRectPainter(color, radius, height);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _RoundedCornerRectPainter extends BoxPainter {
  final Paint _paint;
  final double radius;
  final double height;

  _RoundedCornerRectPainter(Color color, this.radius, this.height)
      : _paint = Paint()
    ..color = color
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {

    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(
              offset.dx,
              cfg.size!.height - height,// - 5,
              offset.dx + cfg.size!.width,
              cfg.size!.height,// - 5
          ),
          bottomRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        _paint);
  }
}