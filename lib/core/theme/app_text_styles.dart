import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTextStyles {
  static const TextStyle appTitle = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.title,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.heading,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.body,           // ✅ FIXED
    fontWeight: FontWeight.w400,
    color: AppColors.secondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.body,
    fontWeight: FontWeight.w600,
    color: Colors.white,
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
