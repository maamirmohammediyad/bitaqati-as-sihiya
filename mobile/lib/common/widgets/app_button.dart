import 'package:flutter/material.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    final buttonStyle = _buildButtonStyle();

    final child = _buildChild();

    if (size == ButtonSize.small) {
      return ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle,
        child: child,
      );
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: child,
        ),
      );
    }

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: buttonStyle,
      child: child,
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: size == ButtonSize.small ? 16 : 20,
        width: size == ButtonSize.small ? 16 : 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size == ButtonSize.small ? 16 : 20),
          const SizedBox(width: 8),
          Text(label, style: _textStyle),
        ],
      );
    }

    return Text(label, style: _textStyle);
  }

  ButtonStyle _buildButtonStyle() {
    final borderRadius = BorderRadius.circular(
      size == ButtonSize.small ? 8 : 12,
    );
    final padding = this.padding ?? _defaultPadding;

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey400,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.grey100,
          disabledForegroundColor: AppColors.grey400,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: const BorderSide(color: AppColors.primary),
          ),
        );
      case ButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey400,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case ButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.grey400,
          elevation: 0,
          padding: padding,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );
      case ButtonType.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.grey400,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: onPressed != null ? AppColors.primary : AppColors.grey300,
            ),
          ),
        );
    }
  }

  EdgeInsets get _defaultPadding {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  Color get _textColor {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.danger:
        return AppColors.white;
      case ButtonType.secondary:
      case ButtonType.text:
      case ButtonType.outline:
        return AppColors.primary;
    }
  }
}

enum ButtonType { primary, secondary, danger, text, outline }

enum ButtonSize { small, medium, large }
