import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';

class Glassmorphism {
  Glassmorphism._();

  static BoxDecoration light({
    double borderRadius = 16.0,
    double blurIntensity = 20.0,
    double opacity = 0.8,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: AppColors.white.withValues(alpha: opacity),
      border: Border.all(
        color: AppColors.glassBorderLight,
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.glassShadowLight,
          blurRadius: blurIntensity,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
        const BoxShadow(
          color: AppColors.glassShadowLight,
          blurRadius: 60,
          spreadRadius: -10,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration dark({
    double borderRadius = 16.0,
    double blurIntensity = 20.0,
    double opacity = 0.7,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: AppColors.grey800.withValues(alpha: opacity),
      border: Border.all(
        color: AppColors.glassBorderDark,
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.glassShadowDark,
          blurRadius: blurIntensity,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
        const BoxShadow(
          color: AppColors.glassShadowDark,
          blurRadius: 60,
          spreadRadius: -10,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration custom({
    required Color backgroundColor,
    required Color borderColor,
    required Color shadowColor,
    double borderRadius = 16.0,
    double blurIntensity = 20.0,
    double opacity = 0.8,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: backgroundColor.withValues(alpha: opacity),
      border: Border.all(
        color: borderColor,
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: blurIntensity,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: shadowColor,
          blurRadius: 60,
          spreadRadius: -10,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration gradient({
    required List<Color> colors,
    double borderRadius = 16.0,
    double blurIntensity = 20.0,
    bool beginTopLeft = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: colors,
        begin: beginTopLeft ? Alignment.topLeft : Alignment.topRight,
        end: beginTopLeft ? Alignment.bottomRight : Alignment.bottomLeft,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.3),
          blurRadius: blurIntensity,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class GlassEffect extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool isDark;

  const GlassEffect({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: isDark
          ? Glassmorphism.dark(borderRadius: borderRadius)
          : Glassmorphism.light(borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
