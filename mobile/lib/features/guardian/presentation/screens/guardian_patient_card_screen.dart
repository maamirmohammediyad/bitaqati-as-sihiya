import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_dashboard_provider.dart';

class GuardianPatientCardScreen extends ConsumerWidget {
  const GuardianPatientCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardian = ref.watch(authProvider).user;
    final patients = guardian?.patients ?? const [];
    final patient = patients.isEmpty ? null : patients.first;
    final guardianVerified = guardian?.isVerificationApproved ?? false;

    if (patient == null) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'لا يوجد مريض مرتبط بحسابك حالياً.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final dashboardAsync = ref.watch(
      guardianPatientDashboardProvider(patient.id),
    );

    final qrTokenAsync = guardianVerified
        ? ref.watch(guardianPatientQrTokenProvider(patient.id))
        : null;

    Future<void> refresh() async {
      ref.invalidate(guardianPatientDashboardProvider(patient.id));

      if (guardianVerified) {
        ref.invalidate(guardianPatientQrTokenProvider(patient.id));
      }

      await ref.read(
        guardianPatientDashboardProvider(patient.id).future,
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بطاقة المريض'),
          centerTitle: true,
        ),
        body: dashboardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => _LoadError(
            message: 'تعذر تحميل بيانات المريض.',
            onRetry: () {
              ref.invalidate(
                guardianPatientDashboardProvider(patient.id),
              );
            },
          ),
          data: (dashboard) => RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (!guardianVerified) ...[
                  _VerificationRequiredCard(
                    verificationStatus: guardian?.verificationStatus,
                  ),
                  const SizedBox(height: 16),
                ],
                _PatientIdentityCard(
                  dashboard: dashboard,
                  qrTokenAsync: qrTokenAsync,
                  canShowQr: guardianVerified,
                ),
                const SizedBox(height: 16),
                _MedicalSummaryCard(
                  dashboard: dashboard,
                ),
                const SizedBox(height: 16),
                _EmergencySummaryCard(
                  dashboard: dashboard,
                  onPressed: () {
                    context.pushNamed(
                      'guardianPatientEmergencies',
                      pathParameters: {
                        'id': dashboard.patient.id,
                      },
                      extra: dashboard.patient.fullName,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _FilesSummaryCard(
                  dashboard: dashboard,
                  onPressed: () {
                    context.pushNamed(
                      'guardianPatientMedicalFiles',
                      pathParameters: {
                        'id': dashboard.patient.id,
                      },
                      extra: dashboard.patient,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationRequiredCard extends StatelessWidget {
  final String? verificationStatus;

  const _VerificationRequiredCard({
    required this.verificationStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = verificationStatus?.trim().toLowerCase() ?? '';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    final color = isRejected ? Colors.red : Colors.orange;
    final title = isRejected
        ? 'تم رفض طلب التحقق'
        : isPending
            ? 'طلب التحقق قيد المراجعة'
            : 'التحقق من الحساب مطلوب';

    final message = isRejected
        ? 'لا يمكن عرض رمز QR للمريض حتى يتم تقديم مستند تحقق جديد واعتماده.'
        : isPending
            ? 'سيظهر رمز QR للمريض بعد اعتماد طلب التحقق من الإدارة.'
            : 'يجب رفع مستند إثبات الهوية واعتماد الحساب قبل عرض رمز QR للمريض.';

    return Card(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(
                isRejected
                    ? Icons.cancel_outlined
                    : Icons.verified_user_outlined,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientIdentityCard extends StatelessWidget {
  final GuardianPatientDashboard dashboard;
  final AsyncValue<String>? qrTokenAsync;
  final bool canShowQr;

  const _PatientIdentityCard({
    required this.dashboard,
    required this.qrTokenAsync,
    required this.canShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final patient = dashboard.patient;
    final profile = dashboard.profile;

    final patientName = profile?.fullName?.trim().isNotEmpty == true
        ? profile!.fullName!.trim()
        : patient.fullName;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              patientName,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 6),
            Text(
              'كود المريض: ${patient.patientCode ?? 'غير متوفر'}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            if (!canShowQr)
              const _QrVerificationLocked()
            else
              _QrSection(qrTokenAsync: qrTokenAsync!),
          ],
        ),
      ),
    );
  }
}

class _QrVerificationLocked extends StatelessWidget {
  const _QrVerificationLocked();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 52,
          ),
          SizedBox(height: 12),
          Text(
            'رمز QR غير متاح حالياً',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'يتطلب عرض الرمز اعتماد تحقق حساب ولي الأمر.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QrSection extends StatelessWidget {
  final AsyncValue<String> qrTokenAsync;

  const _QrSection({
    required this.qrTokenAsync,
  });

  @override
  Widget build(BuildContext context) {
    return qrTokenAsync.when(
      loading: () => const SizedBox(
        height: 190,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => const SizedBox(
        height: 190,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_2_outlined,
                size: 54,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'تعذر إنشاء رمز QR حالياً',
              ),
            ],
          ),
        ),
      ),
      data: (token) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: token,
              size: 190,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'يُستخدم هذا الرمز للوصول إلى المعلومات الصحية في حالات الطوارئ.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MedicalSummaryCard extends StatelessWidget {
  final GuardianPatientDashboard dashboard;

  const _MedicalSummaryCard({
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final profile = dashboard.profile;

    final bloodGroup = profile?.bloodGroup ?? 'غير محددة';
    final gender = _genderLabel(profile?.gender);
    final birthDate = profile?.dateOfBirth ?? 'غير محدد';
    final allergies = _valueOrFallback(profile?.allergies);
    final chronicDiseases = _valueOrFallback(profile?.chronicDiseases);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardTitle(
              icon: Icons.medical_information_outlined,
              title: 'الملخص الطبي',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.bloodtype_outlined,
                  label: 'فصيلة الدم',
                  value: bloodGroup,
                ),
                _InfoChip(
                  icon: Icons.person_outline_rounded,
                  label: 'الجنس',
                  value: gender,
                ),
                _InfoChip(
                  icon: Icons.cake_outlined,
                  label: 'الميلاد',
                  value: birthDate,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'الحساسية',
              value: allergies,
            ),
            const Divider(height: 24),
            _DetailRow(
              label: 'الأمراض المزمنة',
              value: chronicDiseases,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencySummaryCard extends StatelessWidget {
  final GuardianPatientDashboard dashboard;
  final VoidCallback onPressed;

  const _EmergencySummaryCard({
    required this.dashboard,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final lastEvent = dashboard.emergency.lastEvent;
    final hasEmergency = dashboard.emergency.count > 0;
    final color = hasEmergency ? Colors.red : Colors.green;

    final subtitle = hasEmergency
        ? 'عدد الحالات: ${dashboard.emergency.count}'
            '${lastEvent?.createdAt != null ? '\nآخر حالة: ${lastEvent!.createdAt}' : ''}'
        : 'لم يتم تسجيل أي حالة طوارئ للمريض';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            Icons.sos_rounded,
            color: color,
          ),
        ),
        title: Text(
          hasEmergency ? 'سجل الطوارئ' : 'لا توجد حالات طوارئ',
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onPressed,
      ),
    );
  }
}

class _FilesSummaryCard extends StatelessWidget {
  final GuardianPatientDashboard dashboard;
  final VoidCallback onPressed;

  const _FilesSummaryCard({
    required this.dashboard,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.folder_shared_outlined),
        ),
        title: const Text('الملفات الطبية'),
        subtitle: Text(
          dashboard.medicalFiles.count == 0
              ? 'لا توجد ملفات طبية حالياً'
              : '${dashboard.medicalFiles.count} ملف طبي',
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onPressed,
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text('$label: $value'),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

String _genderLabel(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'male':
      return 'ذكر';
    case 'female':
      return 'أنثى';
    default:
      return 'غير محدد';
  }
}

String _valueOrFallback(String? value) {
  final normalized = value?.trim() ?? '';

  if (normalized.isEmpty) {
    return 'لا توجد بيانات';
  }

  return normalized;
}