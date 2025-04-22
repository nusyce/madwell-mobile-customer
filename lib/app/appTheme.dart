import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

enum AppTheme { dark, light }

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.light: ThemeData(
    useMaterial3: true,
    timePickerTheme: TimePickerThemeData(
      dialBackgroundColor: AppColors.lightAccentColor.withValues(alpha: 0.1),
      backgroundColor: AppColors.lightPrimaryColor,
      hourMinuteTextColor: AppColors.lightAccentColor,
      hourMinuteColor: AppColors.lightAccentColor.withValues(alpha: 0.1),
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.lightAccentColor),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.lightAccentColor),
      ),
      dayPeriodColor: AppColors.lightAccentColor,
      dayPeriodTextColor: AppColors.lightSubHeadingColor1,
      dialHandColor: AppColors.lightAccentColor,
    ),
    scaffoldBackgroundColor: AppColors.lightPrimaryColor,
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimaryColor,
    secondaryHeaderColor: AppColors.lightSubHeadingColor1,
    fontFamily: "Lexend",
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightAccentColor,
      selectionHandleColor: AppColors.lightAccentColor,
    ),
  ),
  //
  AppTheme.dark: ThemeData(
    useMaterial3: true,
    timePickerTheme: TimePickerThemeData(
      dialBackgroundColor: AppColors.darkAccentColor.withValues(alpha: 0.1),
      backgroundColor: AppColors.darkPrimaryColor,
      hourMinuteTextColor: AppColors.darkAccentColor,
      hourMinuteColor: AppColors.darkPrimaryColor.withValues(alpha: 0.1),
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.darkAccentColor),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.darkAccentColor),
      ),
      dayPeriodColor: AppColors.darkAccentColor,
      dayPeriodTextColor: AppColors.darkSubHeadingColor1,
      dialHandColor: AppColors.darkAccentColor,
    ),
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimaryColor,
    secondaryHeaderColor: AppColors.darkSubHeadingColor1,
    scaffoldBackgroundColor: AppColors.darkPrimaryColor,
    fontFamily: "Lexend",
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkAccentColor,
      selectionHandleColor: AppColors.darkAccentColor,
    ),
  )
};
