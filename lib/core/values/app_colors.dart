/// Copyright, 2022, by the authors. All rights reserved.
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Extra colors for the app.
class ExtraColors {
  Color scaffoldBackground;
  Color dialogBackground;
  Color appBarBackground;

  ExtraColors(
      this.scaffoldBackground, this.dialogBackground, this.appBarBackground);
}

/// App colors.
abstract class AppColors {
  /// Global color for light and dark theme
  static const Color disabledButtonColor = Color(0xFFB1BCD0);
  static const Color enabledButtonColor = Color(0xFFFF2323);
  static const Color appBadgeColor = Color(0xFFFF2323);

  /// Bookmark color for the post card.
  static const Color enabledBookmarkButtonColor = Color(0xFF010A1C);

  /// Primary button color
  static const Color appColorBlue = Color(0xFF125BE4);
  static const Color appColorRed = Color(0xFFFF2323);

  /// Custom colors plate
  static const primaryLight = Color(0xFFFFFFFF);
  static const primaryDark = Color(0xFF000000);
  static const secondaryLight = Color(0xFFF6F7F8);
  static const secondaryDark = Color(0xFF1D1C29);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF323647);
  static const appBarLight = Color(0xFFFFFFFF);
  static const appBarDark = Color(0xFF000000);
  static const textColorLight = Color(0xFF010A1C);
  static const textColorDark = Color(0xFFF8F8F8);
  static const cardBgLight = Color(0xFFF6F7F8);
  static const cardBgDark = Color(0xFF212230);

  static const senderMsgBubbleLight = Color(0xFFFFFFFF);
  static const senderMsgBubbleDark = Color(0xFF000000);

  static const receiverMsgBubbleLight = Color(0xFFEEEDE7);
  static const receiverMsgBubbleDark = Color(0xFF010A1C);

  /// Smart colors
  static Color primaryBackground(bool value) => value?primaryDark:primaryLight;
  static Color secondaryBackground(bool value) => value?secondaryDark:secondaryLight;
  static Color surfaceBackground(bool value) => value?surfaceDark:surfaceLight;
  static Color appBarBackground(bool value) => value?appBarDark:appBarLight;
  static Color textColor(bool value) => value?textColorDark:textColorLight;
  static Color cardBackground(bool value) => value?cardBgDark:cardBgLight;

  static Color senderMessageBubbleBackground(bool value) => value?senderMsgBubbleDark:senderMsgBubbleLight;
  static Color receiverMessageBubbleBackground(bool value) => value?receiverMsgBubbleDark:receiverMsgBubbleLight;

  static LinearGradient linearGradient = LinearGradient(
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.5),
        Colors.black.withOpacity(0.4),
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.2),
        Colors.black.withOpacity(0.01),
      ],
      stops: const [
        0.0,
        0.25,
        0.5,
        0.75,
        1.0,
      ]);

  /// FlexScheme light theme colors.
  static const ColorScheme flexSchemeLight = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xffffffff),
    onPrimary: Color(0xff000000),
    primaryContainer: Color(0xffa0c2ed),
    onPrimaryContainer: Color(0xff1c2128),
    secondary: Color(0xffd26900),
    onSecondary: Color(0xffffffff),
    secondaryContainer: Color(0xffffd270),
    onSecondaryContainer: Color(0xff282414),
    tertiary: Color(0xff5c5c95),
    onTertiary: Color(0xffffffff),
    tertiaryContainer: Color(0xffc8dbf8),
    onTertiaryContainer: Color(0xff222528),
    error: Color(0xffb00020),
    onError: Color(0xffffffff),
    errorContainer: Color(0xfffcd8df),
    onErrorContainer: Color(0xff282526),
    outline: Color(0xff606060),
    background: Color(0xfff7f8fa),
    onBackground: Color(0xff131313),
    surface: Color(0xfffbfbfc),
    onSurface: Color(0xff090909),
    surfaceVariant: Color(0xfff7f8fa),
    onSurfaceVariant: Color(0xff131313),
    inverseSurface: Color(0xff101112),
    onInverseSurface: Color(0xfff5f5f5),
    inversePrimary: Color(0xff8dacdd),
    shadow: Color(0xff000000),
  );

  /// FlexScheme dark theme colors.
  static const ColorScheme flexSchemeDark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xff000000),
    onPrimary: Color(0xff1a1e1e),
    primaryContainer: Color(0xff3873ba),
    onPrimaryContainer: Color(0xffddebfb),
    secondary: Color(0xffffd270),
    onSecondary: Color(0xff1e1e13),
    secondaryContainer: Color(0xffd26900),
    onSecondaryContainer: Color(0xffffe8d0),
    tertiary: Color(0xffc9cbfc),
    onTertiary: Color(0xff1d1d1e),
    tertiaryContainer: Color(0xff535393),
    onTertiaryContainer: Color(0xffe3e3f2),
    error: Color(0xffcf6679),
    onError: Color(0xff1e1214),
    errorContainer: Color(0xffb1384e),
    onErrorContainer: Color(0xfff9dde2),
    outline: Color(0xff989898),
    background: Color(0xff1a1c1e),
    onBackground: Color(0xffe4e4e4),
    surface: Color(0xff151617),
    onSurface: Color(0xfff1f1f1),
    surfaceVariant: Color(0xff191b1d),
    onSurfaceVariant: Color(0xffe3e4e4),
    inverseSurface: Color(0xfffcfdfe),
    onInverseSurface: Color(0xff0e0e0e),
    inversePrimary: Color(0xff586573),
    shadow: Color(0xff000000),
  );

  // Light Extra
  static ExtraColors extraColorsLight = ExtraColors(const Color(0xFFF6F7F8),
      const Color(0xFFFFFFFF), const Color(0xFFFFFFFF));

  // Dark Extra
  static ExtraColors extraColorsDark = ExtraColors(const Color(0xFF212230),
      const Color(0xFF1D1C29), const Color(0xFF1D1C29));
}
