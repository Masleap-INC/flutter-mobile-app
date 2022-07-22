import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';

class HeartAnimeWidget extends StatelessWidget {
  final double size;

  const HeartAnimeWidget(this.size, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Animator(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.5, end: 1.4),
      curve: Curves.elasticOut,
      builder: (context, anim, child) => Transform.scale(
        scale: anim.value as double,
        child: Icon(
          Icons.favorite_rounded,
          size: size,
          color: AppColors.enabledButtonColor,
        ),
      ),
    );
  }
}
