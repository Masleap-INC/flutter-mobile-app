import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/values/app_colors.dart';

// import '../core/values/app_colors.dart';

class Themes {
  static final light = FlexThemeData.light(
    colors: FlexSchemeColor(
      primary: AppColors.flexSchemeLight.primary,
      primaryContainer: AppColors.flexSchemeLight.primaryContainer,
      secondary: AppColors.flexSchemeLight.secondary,
      secondaryContainer: AppColors.flexSchemeLight.secondaryContainer,
      tertiary: AppColors.flexSchemeLight.tertiary,
      tertiaryContainer: AppColors.flexSchemeLight.tertiaryContainer,
      appBarColor: AppColors.flexSchemeLight.primary,
      error: AppColors.flexSchemeLight.error,
      errorContainer: AppColors.flexSchemeLight.errorContainer,
    ),
    // surface: AppColors.flexSchemeLight.surface,
    // background: AppColors.flexSchemeLight.background,
    // scaffoldBackground: AppColors.extraColorsLight.scaffoldBackground,
    // dialogBackground: AppColors.extraColorsLight.dialogBackground,
    // appBarBackground: AppColors.extraColorsLight.appBarBackground,
    // onSurface: AppColors.flexSchemeLight.onSurface,
    // onBackground: AppColors.flexSchemeLight.onBackground,
    // onError: AppColors.flexSchemeLight.onError,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 10,
    appBarStyle: FlexAppBarStyle.material,
    appBarOpacity: 1,
    tooltipsMatchBackground: true,
    surfaceTint: const Color(0xffffffff),
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      blendOnColors: true,
      defaultRadius: 8.0,
      textButtonRadius: 40.0,
      elevatedButtonRadius: 40.0,
      outlinedButtonRadius: 40.0,
      switchSchemeColor: SchemeColor.onPrimary,
      checkboxSchemeColor: SchemeColor.onPrimary,
      radioSchemeColor: SchemeColor.onPrimary,
      inputDecoratorSchemeColor: SchemeColor.onBackground,
      elevatedButtonSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: false,
      inputDecoratorRadius: 15.0,
      bottomNavigationBarBackgroundSchemeColor: SchemeColor.primary,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );

  static final dark = FlexThemeData.dark(
    colors: FlexSchemeColor(
      primary: AppColors.flexSchemeDark.primary,
      primaryContainer: AppColors.flexSchemeDark.primaryContainer,
      secondary: AppColors.flexSchemeDark.secondary,
      secondaryContainer: AppColors.flexSchemeDark.secondaryContainer,
      tertiary: AppColors.flexSchemeDark.tertiary,
      tertiaryContainer: AppColors.flexSchemeDark.tertiaryContainer,
      appBarColor: AppColors.flexSchemeDark.primary,
      error: AppColors.flexSchemeDark.error,
      errorContainer: AppColors.flexSchemeDark.errorContainer,
    ),
    // surface: AppColors.flexSchemeDark.surface,
    // background: AppColors.flexSchemeDark.background,
    // scaffoldBackground: AppColors.extraColorsDark.scaffoldBackground,
    // dialogBackground: AppColors.extraColorsDark.dialogBackground,
    // appBarBackground: AppColors.extraColorsDark.appBarBackground,
    // onSurface: AppColors.flexSchemeDark.onSurface,
    // onBackground: AppColors.flexSchemeDark.onBackground,
    // onError: AppColors.flexSchemeDark.onError,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 15,
    appBarStyle: FlexAppBarStyle.material,
    appBarOpacity: 1,
    tooltipsMatchBackground: true,
    surfaceTint: const Color(0xff000000),
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 30,
      defaultRadius: 8.0,
      textButtonRadius: 40.0,
      elevatedButtonRadius: 40.0,
      outlinedButtonRadius: 40.0,
      switchSchemeColor: SchemeColor.onPrimary,
      checkboxSchemeColor: SchemeColor.onPrimary,
      radioSchemeColor: SchemeColor.onPrimary,
      elevatedButtonSchemeColor: SchemeColor.primary,
      inputDecoratorSchemeColor: SchemeColor.onBackground,
      inputDecoratorIsFilled: false,
      inputDecoratorRadius: 15.0,
      bottomNavigationBarBackgroundSchemeColor: SchemeColor.onSecondary,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );
}
