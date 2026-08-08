import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/widgets/health_card.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HealthCardScreen extends ConsumerWidget {
  const HealthCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.myHealthCard),
        ),
        body: const Center(
          child: Text('لا يوجد مريض مسجّل حالياً'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myHealthCard),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // البطاقة الصحية نفسها
            HealthCardWidget(
  patientName: user.fullName,
  nationalId: user.nationalId,
  bloodType: user.bloodType ?? 'N/A',
  allergies: 'None',
  chronicDiseases: null,
  cardNumber: user.patientCode ?? 'N/A',
  validUntil: '12/2028',
            ),
            const SizedBox(height: 24),

            // قسم QR
            Text(
              localizations.qrCode,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 4),
            Text(
              localizations.scanQr,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Center(
  child: GestureDetector(
    onTap: () {
      // افتح شاشة الكود الصحي
      context.go('/patient/qr');
    },
    child: Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: const Center(
        child: Icon(
          Icons.qr_code_2_rounded,
          size: 140,
          color: AppColors.grey900,
        ),
      ),
    ),
  ),
),
            const SizedBox(height: 24),

            // تفاصيل البطاقة
            Text(
              localizations.cardNumber,
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: user.patientCode ?? 'BQS-2024-00001',
              icon: Icons.tag_outlined,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: localizations.ministryOfHealth,
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 24),

            // إجراءات
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined),
                    label: Text(localizations.downloadCard),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined),
                    label: Text(localizations.shareCard),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final IconData icon;

  const _DetailRow({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey400),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}