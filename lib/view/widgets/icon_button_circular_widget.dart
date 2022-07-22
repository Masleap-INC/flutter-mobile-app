import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IconButtonCircularWidget extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final double? containerRadius;
  final EdgeInsets padding;
  final Color backColor;
  final Color? splashColor;

  const IconButtonCircularWidget(
      {Key? key,
      required this.icon,
      required this.onTap,
      this.containerRadius = 36,
      this.backColor = Colors.black26,
      this.splashColor,
      this.padding = const EdgeInsets.all(0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap,
        child: ClipOval(
          child: Material(
            color: backColor,
            child: InkWell(
              splashColor: splashColor ?? Colors.white.withOpacity(0.2),
              child: SizedBox(
                  width: containerRadius, height: containerRadius, child: icon),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
