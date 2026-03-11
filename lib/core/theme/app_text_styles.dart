import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTextStyles {
  static const TextStyle appTitle = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.title,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.heading,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.body,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.body,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.body,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.small,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle statusSuccess = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.caption,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );

  static const TextStyle statusError = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.caption,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.caption,
    fontWeight: FontWeight.w400,
    color: AppColors.textDisabled,
  );
}
