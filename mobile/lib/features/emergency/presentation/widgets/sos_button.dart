import 'package:flutter/material.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';

class SosButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isActivated;
  final double size;

  const SosButton({
    super.key,
    this.onPressed,
    this.isActivated = false,
    this.size = 160,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.sosRed.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Material(
              color: widget.isActivated
                  ? AppColors.sosRedDark
                  : AppColors.sosRed,
              shape: const CircleBorder(),
              elevation: 8,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onPressed,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: widget.size * 0.25,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SOS',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: widget.size * 0.18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
