import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_dashboard_provider.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_emergencies_provider.dart';

class GuardianDashboard extends ConsumerWidget {
  const GuardianDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final patients = user.patients;
    final patient = patients.isNotEmpty ? patients.first : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final shouldExit =
            await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('الخروج من التطبيق'),
                content: const Text('هل تريد الخروج من التطبيق؟'),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(true),
                    child: const Text('خروج'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة تحكم الولي'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: patient == null
                  ? null
                  : () => _refreshPatientData(ref, patient.id),
            ),
            IconButton(
              tooltip: 'تسجيل الخروج',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _logout(context, ref),
            ),
          ],
        ),
        body: SafeArea(
          child: patient == null
              ? _EmptyGuardianView(
                  guardianName: user.fullName,
                )
              : _GuardianWithPatient(
                  guardianName: user.fullName,
                  verificationStatus: user.verificationStatus,
                  patientId: patient.id,
                ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();

    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> _refreshPatientData(WidgetRef ref, String patientId) async {
    ref.invalidate(guardianPatientDashboardProvider(patientId));
    ref.invalidate(guardianPatientDashboardWithNotifyProvider(patientId));
    ref.invalidate(guardianPatientEmergenciesProvider(patientId));

    await ref.read(
      guardianPatientDashboardProvider(patientId).future,
    );
  }
}

class _EmptyGuardianView extends StatelessWidget {
  final String guardianName;

  const _EmptyGuardianView({
    required this.guardianName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.person_search_outlined,
          size: 72,
          color: Colors.grey,
        ),
        const SizedBox(height: 20),
        Text(
          'مرحباً $guardianName',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 12),
        const Text(
          'لا يوجد مريض مرتبط بحسابك حالياً.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'يمكنك ربط مريض باستخدام كود المريض من شاشة التسجيل أو من خيار ربط مريض عند توفره.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _GuardianWithPatient extends ConsumerWidget {
  final String guardianName;
  final String verificationStatus;
  final String patientId;

  const _GuardianWithPatient({
    required this.guardianName,
    required this.verificationStatus,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(
      guardianPatientDashboardWithNotifyProvider(patientId),
    );

    Future<void> refresh() async {
      ref.invalidate(guardianPatientDashboardProvider(patientId));
      ref.invalidate(guardianPatientDashboardWithNotifyProvider(patientId));
      ref.invalidate(guardianPatientEmergenciesProvider(patientId));

      await ref.read(
        guardianPatientDashboardProvider(patientId).future,
      );
    }

    return dashboardAsync.when(
      loading: () => _DashboardLoading(
        guardianName: guardianName,
      ),
      error: (error, _) => _DashboardError(
        guardianName: guardianName,
        onRetry: refresh,
      ),
      data: (dashboard) => RefreshIndicator(
        onRefresh: refresh,
        child: _GuardianDashboardContent(
          guardianName: guardianName,
          verificationStatus: verificationStatus,
          dashboard: dashboard,
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  final String guardianName;

  const _DashboardLoading({
    required this.guardianName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'مرحباً $guardianName',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        const Text(
          'جاري تحميل بيانات المريض المرتبط بحسابك...',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 40),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String guardianName;
  final Future<void> Function() onRetry;

  const _DashboardError({
    required this.guardianName,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.cloud_off_rounded,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          'مرحباً $guardianName',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        const Text(
          'تعذر تحميل بيانات المريض المرتبط بحسابك.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ),
      ],
    );
  }
}

class _GuardianDashboardContent extends ConsumerWidget {
  final String guardianName;
  final String verificationStatus;
  final GuardianPatientDashboard dashboard;

  const _GuardianDashboardContent({
    required this.guardianName,
    required this.verificationStatus,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = dashboard.patient;
    final profile = dashboard.profile;

    final isProfileComplete = profile?.isProfileComplete ?? false;
    final isVerificationApproved =
        verificationStatus.trim().toLowerCase() == 'approved';

    final emergenciesAsync = ref.watch(
      guardianPatientEmergenciesProvider(patient.id),
    );

    final hasUnreadEmergency = emergenciesAsync.maybeWhen(
      data: (events) => events.any((event) => !event.isRead),
      orElse: () => false,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(
          'مرحباً $guardianName',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 4),
        Text(
          'متابعة بيانات ${patient.fullName} الصحية من مكان واحد.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (!isVerificationApproved) ...[
          _VerificationStatusCard(
            verificationStatus: verificationStatus,
          ),
          const SizedBox(height: 12),
        ],
        _EmergencyBanner(
          emergencyCount: dashboard.emergency.count,
          lastEmergencyAt:
              dashboard.emergency.lastEvent?.createdAt ?? 'لا يوجد سجل',
          hasUnreadEmergency: hasUnreadEmergency,
          onTap: () async {
            await context.pushNamed(
              'guardianPatientEmergencies',
              pathParameters: {
                'id': patient.id,
              },
              extra: patient.fullName,
            );

            ref.invalidate(guardianPatientEmergenciesProvider(patient.id));
            ref.invalidate(guardianPatientDashboardProvider(patient.id));
            ref.invalidate(
              guardianPatientDashboardWithNotifyProvider(patient.id),
            );
          },
        ),
        const SizedBox(height: 12),
        _PatientCardEntry(
          isVerificationApproved: isVerificationApproved,
          onTap: () {
            if (!isVerificationApproved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'يجب اعتماد تحقق حساب ولي الأمر أولاً لعرض رمز QR.',
                  ),
                ),
              );
              return;
            }

            context.go('/guardian/card');
          },
        ),
        const SizedBox(height: 12),
        _ProfileCompletionCard(
          isComplete: isProfileComplete,
          patientId: patient.id,
          onUpdated: () {
            ref.invalidate(guardianPatientDashboardProvider(patient.id));
            ref.invalidate(
              guardianPatientDashboardWithNotifyProvider(patient.id),
            );
          },
        ),
        const SizedBox(height: 12),
        _BasicMedicalInfoCard(
          profile: profile,
        ),
        const SizedBox(height: 12),
        _MedicalFilesCard(
          filesCount: dashboard.medicalFiles.count,
          onTap: () {
            context.pushNamed(
              'guardianPatientMedicalFiles',
              pathParameters: {
                'id': patient.id,
              },
              extra: patient,
            );
          },
        ),
      ],
    );
  }
}

class _VerificationStatusCard extends StatelessWidget {
  final String verificationStatus;

  const _VerificationStatusCard({
    required this.verificationStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = verificationStatus.trim().toLowerCase();
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    final color = isRejected ? Colors.red : Colors.orange;
    final icon = isRejected
        ? Icons.cancel_outlined
        : isPending
            ? Icons.hourglass_top_rounded
            : Icons.verified_user_outlined;

    final title = isRejected
        ? 'تم رفض التحقق من الحساب'
        : isPending
            ? 'التحقق من الحساب قيد المراجعة'
            : 'التحقق من الحساب مطلوب';

    final message = isRejected
        ? 'لا يمكن الوصول إلى رمز QR حتى تقديم مستند تحقق جديد واعتماده.'
        : isPending
            ? 'سيتم فتح الوصول إلى رمز QR بعد اعتماد المستند من الإدارة.'
            : 'قم برفع مستند إثبات الهوية من الحساب ليتم اعتماد حسابك.';

    return Card(
      color: color.withValues(alpha: 0.08),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(message),
        ),
      ),
    );
  }
}

class _PatientCardEntry extends StatelessWidget {
  final bool isVerificationApproved;
  final VoidCallback onTap;

  const _PatientCardEntry({
    required this.isVerificationApproved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            isVerificationApproved
                ? Icons.badge_outlined
                : Icons.lock_outline_rounded,
          ),
        ),
        title: const Text('بطاقة المريض الصحية'),
        subtitle: Text(
          isVerificationApproved
              ? 'عرض رمز QR والبيانات الطبية الأساسية'
              : 'رمز QR مقفل حتى اعتماد تحقق الحساب',
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  final bool isComplete;
  final String patientId;
  final VoidCallback onUpdated;

  const _ProfileCompletionCard({
    required this.isComplete,
    required this.patientId,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          isComplete
              ? Icons.check_circle_rounded
              : Icons.warning_amber_rounded,
          color: isComplete ? Colors.green : Colors.orange,
        ),
        title: Text(
          isComplete ? 'الملف الطبي مكتمل' : 'الملف الطبي غير مكتمل',
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: Text(
          isComplete
              ? 'بيانات المريض الأساسية مكتملة.'
              : 'أكمل البيانات الطبية والتاريخ المرضي والحساسية.',
          style: AppTextStyles.bodySmall,
        ),
        trailing: TextButton(
          onPressed: () async {
            final wasUpdated = await context.pushNamed<bool>(
              'guardianPatientCompleteProfile',
              pathParameters: {
                'patientId': patientId,
              },
            );

            if (wasUpdated == true && context.mounted) {
              onUpdated();
            }
          },
          child: Text(isComplete ? 'تعديل' : 'إدارة الملف'),
        ),
      ),
    );
  }
}

class _BasicMedicalInfoCard extends StatelessWidget {
  final PatientProfileSummary? profile;

  const _BasicMedicalInfoCard({
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final bloodGroup = profile?.bloodGroup ?? 'غير محددة';
    final gender = _genderLabel(profile?.gender);
    final dateOfBirth = profile?.dateOfBirth ?? 'غير محدد';
    final height =
        profile?.heightCm != null ? '${profile!.heightCm} سم' : 'غير محدد';
    final weight =
        profile?.weightKg != null ? '${profile!.weightKg} كغ' : 'غير محدد';

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البيانات الطبية الأساسية',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoChip(
                  label: 'تاريخ الميلاد',
                  value: dateOfBirth,
                  icon: Icons.cake_outlined,
                ),
                _InfoChip(
                  label: 'فصيلة الدم',
                  value: bloodGroup,
                  icon: Icons.bloodtype_outlined,
                ),
                _InfoChip(
                  label: 'الجنس',
                  value: gender,
                  icon: Icons.person_outline_rounded,
                ),
                _InfoChip(
                  label: 'الطول',
                  value: height,
                  icon: Icons.height_rounded,
                ),
                _InfoChip(
                  label: 'الوزن',
                  value: weight,
                  icon: Icons.monitor_weight_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalFilesCard extends StatelessWidget {
  final int filesCount;
  final VoidCallback onTap;

  const _MedicalFilesCard({
    required this.filesCount,
    required this.onTap,
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
          filesCount == 0
              ? 'لا توجد ملفات طبية حالياً'
              : '$filesCount ملف طبي',
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _EmergencyBanner extends StatelessWidget {
  final int emergencyCount;
  final String lastEmergencyAt;
  final bool hasUnreadEmergency;
  final VoidCallback onTap;

  const _EmergencyBanner({
    required this.emergencyCount,
    required this.lastEmergencyAt,
    required this.hasUnreadEmergency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEmergency = emergencyCount > 0;
    final backgroundColor =
        hasEmergency ? Colors.red.shade50 : Colors.green.shade50;
    final iconColor = hasEmergency ? Colors.red : Colors.green;
    final borderColor =
        hasEmergency ? Colors.red.shade200 : Colors.green.shade200;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.sos_rounded,
                    color: iconColor,
                    size: 32,
                  ),
                  if (hasUnreadEmergency)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasEmergency
                          ? 'سجل حالات الطوارئ'
                          : 'لا توجد حالات طوارئ',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasEmergency
                          ? 'عدد الحالات المسجلة: $emergencyCount'
                          : 'لم يتم تسجيل حالة طوارئ للمريض.',
                      style: AppTextStyles.bodySmall,
                    ),
                    if (hasEmergency)
                      Text(
                        'آخر حالة: $lastEmergencyAt',
                        style: AppTextStyles.bodySmall,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: AppTextStyles.bodySmall,
          ),
        ],
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