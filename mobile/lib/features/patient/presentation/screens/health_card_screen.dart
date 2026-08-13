import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/providers/patient_qr_provider.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/widgets/health_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
class HealthCardScreen extends ConsumerStatefulWidget {
  const HealthCardScreen({super.key});

  @override
  ConsumerState<HealthCardScreen> createState() => _HealthCardScreenState();
}

class _HealthCardScreenState extends ConsumerState<HealthCardScreen> {
  bool _showNationalId = false;

  String _maskNationalId(String nationalId) {
    if (nationalId.isEmpty) return 'غير متوفر';

    if (nationalId.length <= 4) {
      return '*' * nationalId.length;
    }

    final lastFour = nationalId.substring(nationalId.length - 4);
    return '********$lastFour';
  }

  void _toggleNationalId() {
    setState(() {
      _showNationalId = !_showNationalId;
    });
  }

  Future<void> _refreshQr() async {
    ref.invalidate(patientQrTokenProvider);
    await ref.read(patientQrTokenProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final qrTokenAsync = ref.watch(patientQrTokenProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('لا يوجد مريض مسجّل حالياً'),
        ),
      );
    }

    final nationalId = user.nationalId.trim();

    final displayedNationalId = _showNationalId
        ? (nationalId.isEmpty ? 'غير متوفر' : nationalId)
        : _maskNationalId(nationalId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('صحتك تيك'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshQr,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(
              'بطاقتك الصحية الرقمية',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 4),
            Text(
              'اعرض رمز QR والبيانات الصحية الأساسية بطريقة آمنة.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 16),

            qrTokenAsync.when(
              loading: () => _buildHealthCard(
                user: user,
                displayedNationalId: displayedNationalId,
              ),
              error: (_, __) => Column(
                children: [
                  _buildHealthCard(
                    user: user,
                    displayedNationalId: displayedNationalId,
                  ),
                  const SizedBox(height: 12),
                  _QrUnavailableBanner(
                    onRetry: _refreshQr,
                  ),
                ],
              ),
              data: (qrToken) => _buildHealthCard(
                user: user,
                displayedNationalId: displayedNationalId,
                qrData: qrToken.token,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'ملخص البطاقة',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),

            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _CardInfoTile(
                    icon: Icons.badge_outlined,
                    title: 'كود المريض',
                    value: user.patientCode ?? 'غير متوفر',
                  ),
                  const Divider(height: 1),
                  _CardInfoTile(
                    icon: Icons.bloodtype_outlined,
                    title: 'فصيلة الدم',
                    value: user.bloodType ?? 'غير محددة',
                  ),
                  const Divider(height: 1),
                  const _CardInfoTile(
                    icon: Icons.verified_user_outlined,
                    title: 'حالة البطاقة',
                    value: 'نشطة',
                    valueColor: AppColors.success,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'السجل الصحي',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),

            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.folder_copy_outlined),
                    ),
                    title: const Text('الملفات الطبية'),
                    subtitle: const Text(
                      'عرض الملفات الموجودة في سجلك الصحي فقط',
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () {
                      context.push('/patient/files');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.medical_information_outlined),
                    ),
                    title: const Text('السجل الطبي'),
                    subtitle: const Text(
                      'عرض بياناتك الطبية الأساسية',
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () {
                      context.push('/patient/medical-record');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'DZ-HEALTHTECH',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey400,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildHealthCard({
  required User user,
  required String displayedNationalId,
  String? qrData,
}) {
  return HealthCardWidget(
    patientName: user.fullName,
    nationalId: displayedNationalId,
    bloodType: user.bloodType ?? 'غير محددة',
    allergies: null,
    chronicDiseases: null,
    cardNumber: user.patientCode ?? 'غير متوفر',
    validUntil: 'نشطة',
    qrData: qrData,
    showNationalId: _showNationalId,
    onToggleNationalId: _toggleNationalId,
    onOpenQr: qrData == null
        ? null
        : () => context.push('/patient/qr'),
  );
}
}

class _QrUnavailableBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _QrUnavailableBanner({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.qr_code_2_outlined,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'تعذر تحميل رمز QR حاليًا. يمكنك إعادة المحاولة.',
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('إعادة'),
          ),
        ],
      ),
    );
  }
}

class _CardInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _CardInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(title),
      trailing: Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}