import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../core/values/system_overlay.dart';
import '../../core/viewmodel/auth_viewmodel.dart';
import 'themes_setting_view.dart';


class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.common,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              FontAwesomeIcons.angleLeft,
            ),
          ),
          title: const Text("Settings"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(
              height: 1,
            ),

            _settingsButton(
              icon: Icons.account_circle_outlined,
              title: "Account",
              onTap: () {}
            ),
            _settingsButton(
                icon: Icons.notifications_on_outlined,
                title: "Notifications",
                onTap: () {}
            ),
            _settingsButton(
                icon: Icons.color_lens_outlined,
                title: "Themes",
                onTap: ()=> Get.to(const ThemeSettingView())
            ),
            _settingsButton(
                icon: Icons.help_outline_rounded,
                title: "Help",
                onTap: () {}
            ),
            _settingsButton(
                icon: Icons.info_outline_rounded,
                title: "About",
                onTap: () {}
            ),
            const Spacer(),
            const Divider(
              height: 1,
            ),
            _settingsButton(
                icon: Icons.power_settings_new_rounded,
                title: "Sign out",
                onTap: () {
                  Get.back();
                  Get.find<AuthViewModel>().signOut();
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsButton({required String title, required IconData icon, required VoidCallback onTap}) {
    return SizedBox(
      height: 60.h,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Get.theme.iconTheme.color,),
        onPressed: onTap,
        label: Text(
          title,
          style: Get.theme.textTheme.titleMedium,
        ),
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0.0),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shape:
          MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.r),
            ),
          ),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }


}




