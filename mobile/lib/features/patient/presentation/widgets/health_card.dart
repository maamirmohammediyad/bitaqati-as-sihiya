
import 'package:flutter/material.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/glassmorphism.dart';

class HealthCardWidget extends StatelessWidget {
  final String patientName;
  final String nationalId;
  final String bloodType;
  final String? allergies;
  final String? chronicDiseases;
  final String cardNumber;
  final String validUntil;
  final String? qrData;

  const HealthCardWidget({
    super.key,
    required this.patientName,
    required this.nationalId,
    required this.bloodType,
    this.allergies,
    this.chronicDiseases,
    required this.cardNumber,
    required this.validUntil,
    this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: Glassmorphism.gradient(
        colors: [
          AppColors.healthCardGradientStart,
          AppColors.healthCardGradientEnd,
        ],
        borderRadius: 20,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bitaqati As-Sihiya',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'بطاقتي الصحية',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.sos_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 28,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Patient Name
                  // داخل Column قبل الـ SizedBox(height: 12) الحالي
Text(
  patientName,
  style: const TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    height: 1.2,
  ),
),
const SizedBox(height: 4),
Text(
  'National ID: $nationalId',
  style: TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: Colors.white.withValues(alpha: 0.7),
  ),
),
const SizedBox(height: 2),
Text(
  'Patient Code: $cardNumber',
  style: TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: Colors.white.withValues(alpha: 0.7),
  ),
),
                  const SizedBox(height: 12),
                  // Bottom row
                  Row(
                    children: [
                      _InfoChip(label: 'Blood', value: bloodType),
                      const SizedBox(width: 12),
                      if (allergies != null)
                        _InfoChip(label: 'Allergies', value: allergies!),
                      const Spacer(),
                      Text(
                        'Valid: $validUntil',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
