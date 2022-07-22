/// Copyright, 2022, by the authors. All rights reserved.
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inkistry/core/values/app_colors.dart';
import 'package:inkistry/core/values/app_images.dart';
import 'package:inkistry/core/viewmodel/chat_viewmodel.dart';
import '../core/values/system_overlay.dart';
import '../core/viewmodel/auth_viewmodel.dart';
import '../core/viewmodel/control_viewmodel.dart';
import '../core/network_viewmodel.dart';
import 'auth/welcome_view.dart';

/// It is used to control the navigation of the app.
class ControlView extends StatelessWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    /// Return an Observer which is used to control the navigation of the app.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemOverlay.main,
      child: Obx(() {
        /// System overlay style for the app.
        return Get.find<AuthViewModel>().user!.value?.email == null

            /// If the user is not logged in, return the [WelcomeView].
            ? const WelcomeView()

            /// Else, find the [NetworkViewModel] from the [Get.find].
            /// If the network connection is available, return the [ControlView].
            : Get.find<NetworkViewModel>().connectionStatus.value == 1 ||
                    Get.find<NetworkViewModel>().connectionStatus.value == 2
                ?

                /// GetBuilder is used to build the widget when the network connection is available.
                GetBuilder<ControlViewModel>(
                    /// Initialize the [ControlViewModel].
                    init: ControlViewModel(),

                    /// Return scafold from the builder.
                    builder: (controller) => Scaffold(
                      /// Set the body of the scaffold to the current screen of the [ControlViewModel].
                      body: controller.currentScreen,

                      /// Set the bottom navigation bar to the bottom navigation bar of the [ControlViewModel].
                      bottomNavigationBar: const CustomBottomNavigationBar(),
                    ),
                  )

                /// Else, return the [NoInternetConnection] view.
                : const NoInternetConnection();
      }),
    );
  }
}

/// This class build the bottom navigation bar of the app.
/// This is a custom bottom navigation bar.
class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    /// The height of the bottom navigation bar is 60dp.
    /// You can change the height of the bottom navigation bar by changing the value of the variable.
    return SizedBox(
      height: 60.h,

      /// GetBuilder is used to build the bottom navigation bar.
      child: GetBuilder<ControlViewModel>(
        /// Return the bottom navigation bar from the builder.
        builder: (controller) => BottomNavigationBar(
          /// Our bottom navigation bar has no label.
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: AppColors.primaryBackground(Get.isDarkMode),

          /// Elevation is used to give the bottom navigation bar a shadow.
          /// You can change the elevation of the bottom navigation bar by changing the value of the variable.
          elevation: 0,

          /// The background color of the bottom navigation bar is white by default.
          /// If you want to change the background color of the bottom navigation bar,
          /// Uncomment the line of code and change the color of the bottom navigation bar.
          /// backgroundColor: Colors.black38,

          /// Current index is used to set the current screen of the bottom navigation bar.
          /// It value updated when the user clicks on the bottom navigation bar.
          currentIndex: controller.navigatorIndex,

          /// The onTap callback is used to respond to the user clicks on the bottom navigation bar.
          onTap: (index) => controller.changeCurrentScreen(index),

          /// The items of the bottom navigation bar are set to the items of the [ControlViewModel].
          /// It have 5 items.
          items: [
            /// First item of the bottom navigation bar is the home screen.
            customBottomNavigationBarItem(icon: AppImages.navHomeIcon),

            /// Second item of the bottom navigation bar is the search screen.
            customBottomNavigationBarItem(icon: AppImages.navSearchIcon),

            /// Third item of the bottom navigation bar is used to show bottom sheet.
            customBottomNavigationBarItem(icon: AppImages.navUploadIcon),

            /// Fourth item of the bottom navigation bar is the chat screen.
            /// It accept two arguments, icon and badge.
            customBottomNavigationBarItem(
                icon: AppImages.navChatIcon, isChat: true),

            /// Fifth item of the bottom navigation bar is the profile screen.
            BottomNavigationBarItem(
              label: '',

              /// Custom circle avatar is used to show the profile picture of the user.
              /// It have disabled border color
              icon: customCircleAvatar(
                  controller: controller,
                  borderColor: AppColors.disabledButtonColor),
              activeIcon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// When the user clicks on the profile icon, this container will be shown as an activator bar.
                  Container(
                    height: 4.h,
                    width: 20.w,
                    transform: Matrix4.translationValues(0.0, -14.h, 0.0),
                    decoration: BoxDecoration(
                      color: AppColors.enabledButtonColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  /// Custom circle avatar is used to show the profile picture of the user.
                  /// It have enabled border color
                  customCircleAvatar(
                      controller: controller,
                      borderColor: AppColors.enabledButtonColor)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// This function is used to build the custom bottom navigation bar item.
  /// It takes two arguments, icon and badge (newChat).
  /// When the icon is in desabled state and there have a new chat, the badge is shown.
  BottomNavigationBarItem customBottomNavigationBarItem(
      {required String icon, bool isChat = false}) {
    return BottomNavigationBarItem(
      label: '',

      /// Icon with badge is used to show the new chat badge.
      icon: isChat
          ? Obx(() => (Get.find<ChatViewModel>().unreadChat.value > 0 ||
                  Get.find<ChatViewModel>().chatRequest.value > 0)
              ? Badge(
                  shape: BadgeShape.circle,
                  badgeColor: AppColors.appBadgeColor,
                  child: SvgPicture.asset(
                    icon,
                    height: 24,
                    color: AppColors.disabledButtonColor,
                  ),
                )
              : SvgPicture.asset(
                  icon,
                  height: 24,
                  color: AppColors.disabledButtonColor,
                ))

          /// Only icon is used to show the icon.
          : SvgPicture.asset(
              icon,
              height: 24,
              color: AppColors.disabledButtonColor,
            ),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// When the user clicks on the icon, this container will be shown as an activator bar.
          Container(
            height: 4.h,
            width: 20.w,
            transform: Matrix4.translationValues(0.0, -14.h, 0.0),
            decoration: BoxDecoration(
              color: AppColors.enabledButtonColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          /// Svg icon is used to show the icon of the bottom navigation bar.
          SvgPicture.asset(
            icon,
            height: 24,
            color: AppColors.enabledButtonColor,
          )
        ],
      ),
    );
  }

  /// This function is used to build the custom circle avatar.
  Widget customCircleAvatar(
      {required ControlViewModel controller, required Color borderColor}) {
    /// GetBuilder is used to build the custom circle avatar.
    return CircleAvatar(
      radius: 12.0.r,
      backgroundColor: borderColor,

      /// This avatar is used to show the profile picture of the user.
      child: Obx(() => CircleAvatar(
            radius: 11.r,

            /// By default, the profile picture is set to the default profile picture.
            backgroundImage: const AssetImage(AppImages.guestUserLogo),

            /// If the current user is not null and the current user has a profile picture,
            foregroundImage: controller.currentUser.value != null
                ? controller.currentUser.value!.imageUrl != null

                    /// load the profile picture of the current user.
                    ? CachedNetworkImageProvider(
                        controller.currentUser.value!.imageUrl!)

                    /// else, return null.
                    : null
                : null,
          )),
    );
  }
}

/// This class is used to show the network connection error message.
class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.theme;
    /// Return a scaffold with a body.
    return Scaffold(
      /// Every item of the body is in a column and center aligned.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Show the not internet icon.
            SvgPicture.asset(
              AppImages.noInternetIcon,
              height: 100.h,
              color: Theme.of(context).iconTheme.color,
            ),

            /// Space between the icon and the text.
            SizedBox(
              height: 30.h,
            ),

            /// Show thye not internet connection text.
            Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            /// Show the trying to reconnect text.
            Text(
              'Trying to reconnect',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            /// Space between the text and the progress indicator.
            SizedBox(
              height: 30.h,
            ),

            /// Show the progress indicator.0
            const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
