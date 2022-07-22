import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../core/services/themes_service.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_constants.dart';
import '../../core/values/system_overlay.dart';

class ThemeSettingViewController extends GetxController {
  final ThemesService themeService = ThemesService();
  RxString selectedTheme = ''.obs;
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    selectedTheme.value = themeService.getTheme()!;
    switch (selectedTheme.value) {
      case AppConstants.light:
        selectedIndex(0);
        break;
      case AppConstants.dark:
        selectedIndex(1);
        break;
      case AppConstants.systemDefault:
        selectedIndex(2);
        break;
    }
    super.onInit();
  }

  void selectTheme(int index) {
    switch (index) {
      case 0:
        themeService.setTheme(AppConstants.light);
        break;
      case 1:
        themeService.setTheme(AppConstants.dark);
        break;
      case 2:
        themeService.setTheme(AppConstants.systemDefault);
        break;
    }
    selectedIndex(index);
  }
}

class ThemeSettingView extends StatelessWidget {
  const ThemeSettingView({Key? key}) : super(key: key);

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
            title: const Text("Change themes"),
          ),
          body: GetBuilder<ThemeSettingViewController>(
              init: Get.put(ThemeSettingViewController()),
              builder: (controller) {
                return Column(
                  children: [
                    _themesRadioButton(
                      controller: controller,
                      index: 0,
                      icon: Icons.sunny,
                      text: 'Light',
                    ),
                    _themesRadioButton(
                      controller: controller,
                      index: 1,
                      icon: Icons.nights_stay_outlined,
                      text: 'Dark',
                    ),
                    _themesRadioButton(
                      controller: controller,
                      index: 2,
                      icon: Icons.phone_android,
                      text: 'System Default',
                    )
                  ],
                );
              })),
    );
  }

  Widget _themesRadioButton(
      {required ThemeSettingViewController controller,
      required int index,
      required IconData icon,
      required String text}) {
    return Obx(() => RadioListTile(
          value: index,
          groupValue: controller.selectedIndex.value,
          selected: index == controller.selectedIndex.value,
          onChanged: (int? index) => controller.selectTheme(index!),
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: AppColors.appColorRed,
          title: Row(
            children: <Widget>[
              Icon(
                icon,
              ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  text,
                ),
              ),
            ],
          ),
        ));
  }
}
