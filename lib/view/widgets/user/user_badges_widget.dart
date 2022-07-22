import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/user_model.dart';

class UserBadgesWidget extends StatelessWidget {
  final UserModel user;
  final double size;
  final bool secondSizedBox;

  const UserBadgesWidget(
      {Key? key,
      required this.user,
      required this.size,
      this.secondSizedBox = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return Row(
      children: <Widget>[
        if (user.isVerified == true) const SizedBox(width: 5),
        if (user.isVerified!)
          Tooltip(
            message: 'User is Verified',
            child: Image.asset(
              'assets/images/temp_v_mark.png',
              height: size + 2,
              width: size + 2,
            ),
          ),
        if (user.role == 'admin') const SizedBox(width: 5),
        if (user.role == 'admin')
          Tooltip(
            message: 'User is Admin',
            child: Image.asset(
              'assets/images/temp_v_mark.png',
              height: size + 4,
              width: size + 4,
            ),
          ),
        if (user.role == 'admin' && secondSizedBox == true)
          const SizedBox(width: 5),
      ],
    );
  }
}
