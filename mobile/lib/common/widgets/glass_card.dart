import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:bitaqati_as_sihiya/core/theme/glassmorphism.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool isDark;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.isDark = false,
    this.gradientColors,
    this.onTap,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isDark || Theme.of(context).brightness == Brightness.dark;
    final decoration = gradientColors != null
        ? Glassmorphism.gradient(
            colors: gradientColors!,
            borderRadius: borderRadius,
          )
        : isDarkMode
            ? Glassmorphism.dark(borderRadius: borderRadius)
            : Glassmorphism.light(borderRadius: borderRadius);

    final card = Container(
      height: height,
      width: width,
      margin: margin,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}
