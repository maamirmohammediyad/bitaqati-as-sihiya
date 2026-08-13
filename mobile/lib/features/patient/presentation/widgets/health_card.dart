import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HealthCardWidget extends StatelessWidget {
  final String patientName;
  final String nationalId;
  final String bloodType;
  final String? allergies;
  final String? chronicDiseases;
  final String cardNumber;
  final String validUntil;
  final String? qrData;
  final bool showNationalId;
  final VoidCallback? onToggleNationalId;
  final VoidCallback? onOpenQr;

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
    required this.showNationalId,
    this.onToggleNationalId,
    this.onOpenQr,
  });

  @override
  Widget build(BuildContext context) {
    final hasAllergies = allergies != null && allergies!.trim().isNotEmpty;
    final hasChronicDiseases =
        chronicDiseases != null && chronicDiseases!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.healthCardGradientStart,
            AppColors.healthCardGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.healthCardGradientEnd.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              left: -55,
              child: _DecorativeCircle(
                size: 190,
                opacity: 0.08,
              ),
            ),
            Positioned(
              bottom: -65,
              right: -60,
              child: _DecorativeCircle(
                size: 185,
                opacity: 0.07,
              ),
            ),
            Positioned(
              top: 185,
              right: -35,
              child: _DecorativeCircle(
                size: 110,
                opacity: 0.05,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CardHeader(),
                  const SizedBox(height: 22),

                  Center(
                    child: Container(
                      width: 164,
                      height: 164,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: qrData == null || qrData!.trim().isEmpty
                          ? const Center(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: 110,
                                color: AppColors.grey900,
                              ),
                            )
                          : InkWell(
                              onTap: onOpenQr,
                              borderRadius: BorderRadius.circular(10),
                              child: QrImageView(
                                data: qrData!,
                                version: QrVersions.auto,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                                backgroundColor: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'امسح الرمز لعرض البيانات الصحية المصرح بها',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _SectionLabel(label: 'بيانات المريض'),
                  const SizedBox(height: 8),

                  Text(
                    patientName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 23,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _CardField(
                          label: 'كود المريض',
                          value: cardNumber,
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CardField(
                          label: 'فصيلة الدم',
                          value: bloodType,
                          icon: Icons.bloodtype_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: Colors.white.withValues(alpha: 0.92),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الرقم الوطني',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.68),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nationalId,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onToggleNationalId,
                          tooltip: showNationalId
                              ? 'إخفاء الرقم الوطني'
                              : 'إظهار الرقم الوطني',
                          icon: Icon(
                            showNationalId
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (hasAllergies || hasChronicDiseases) ...[
                    const SizedBox(height: 16),
                    _SectionLabel(label: 'معلومات طبية'),
                    const SizedBox(height: 8),
                    if (hasAllergies)
                      _MedicalInfoRow(
                        icon: Icons.warning_amber_rounded,
                        title: 'الحساسية',
                        value: allergies!,
                      ),
                    if (hasAllergies && hasChronicDiseases)
                      const SizedBox(height: 8),
                    if (hasChronicDiseases)
                      _MedicalInfoRow(
                        icon: Icons.medical_information_outlined,
                        title: 'الأمراض المزمنة',
                        value: chronicDiseases!,
                      ),
                  ],

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'البطاقة $validUntil',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'DZ-HEALTHTECH',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white.withValues(alpha: 0.72),
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

class _CardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SvgPicture.asset(
            'assets/icons/icon-card.svg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'صحتك تيك',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'بطاقة صحية رقمية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
            ),
          ),
          child: const Text(
            'نشطة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.68),
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _CardField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.white.withValues(alpha: 0.90),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.66),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MedicalInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.white.withValues(alpha: 0.92),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  height: 1.55,
                  color: Colors.white.withValues(alpha: 0.90),
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}