import 'package:flutter/material.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _cairo = 'Cairo';
  static const String _inter = 'Inter';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _cairo,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.grey900,
    height: 1.2,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _cairo,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.grey900,
    height: 1.2,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _cairo,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.grey900,
    height: 1.3,
  );

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontFamily: _cairo,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.grey900,
    height: 1.3,
  );
  static const TextStyle heading2 = TextStyle(
    fontFamily: _cairo,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.grey900,
    height: 1.3,
  );
  static const TextStyle heading3 = TextStyle(
    fontFamily: _cairo,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.grey900,
    height: 1.4,
  );
  static const TextStyle heading4 = TextStyle(
    fontFamily: _cairo,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.grey900,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.grey700,
    height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey600,
    height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey500,
    height: 1.5,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _cairo,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.grey800,
    height: 1.4,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _cairo,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.grey700,
    height: 1.4,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _cairo,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.grey500,
    height: 1.4,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey400,
    height: 1.4,
  );

  // Button
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _cairo,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _cairo,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _cairo,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  // Overline
  static const TextStyle overline = TextStyle(
    fontFamily: _inter,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.grey400,
    height: 1.2,
    letterSpacing: 1.0,
  );

  // Link
  static const TextStyle link = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.4,
    decoration: TextDecoration.underline,
  );

  // Number / Digit (for medical data)
  static const TextStyle digitLarge = TextStyle(
    fontFamily: _inter,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.grey900,
    height: 1.1,
  );
  static const TextStyle digitMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.grey900,
    height: 1.1,
  );
}
