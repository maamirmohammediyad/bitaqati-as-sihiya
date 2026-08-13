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
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final patients = user.patients;
    final patient = patients.isNotEmpty ? patients.first : null;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('الخروج من التطبيق'),
                content: const Text('هل تريد الخروج من التطبيق؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: patient == null
                ? _EmptyGuardianView(guardianName: user.fullName)
                : _GuardianWithPatient(
                    guardianName: user.fullName,
                    patientDashboardAsync: ref.watch(
                      guardianPatientDashboardWithNotifyProvider(patient.id),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// في حالة عدم وجود مريض مرتبط
class _EmptyGuardianView extends StatelessWidget {
  final String guardianName;

  const _EmptyGuardianView({required this.guardianName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً $guardianName',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        const Text(
          'لا يوجد مريض مرتبط بحسابك حالياً.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'يمكنك ربط مريض باستخدام كود المريض من شاشة التسجيل أو من زر "ربط مريض".',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: فتح شاشة ربط مريض
          },
          icon: const Icon(Icons.person_add),
          label: const Text('ربط مريض'),
        ),
      ],
    );
  }
}

/// في حالة وجود مريض واحد للولي
class _GuardianWithPatient extends StatelessWidget {
  final String guardianName;
  final AsyncValue<GuardianPatientDashboard> patientDashboardAsync;

  const _GuardianWithPatient({
    required this.guardianName,
    required this.patientDashboardAsync,
  });

  @override
  Widget build(BuildContext context) {
    return patientDashboardAsync.when(
      data: (dashboard) => _GuardianDashboardContent(
        guardianName: guardianName,
        dashboard: dashboard,
      ),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (e, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً $guardianName',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          const Text(
            'تعذر تحميل بيانات المريض المرتبط بحسابك.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            e.toString(),
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// المحتوى الكامل عندما يكون هناك مريض واحد
class _GuardianDashboardContent extends ConsumerWidget {
  final String guardianName;
  final GuardianPatientDashboard dashboard;

  const _GuardianDashboardContent({
    required this.guardianName,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = dashboard.patient;
    final profile = dashboard.profile;
    final isComplete = profile?.isProfileComplete ?? false;

    final emergencyCount = dashboard.emergency.count;
    final lastEmergencyAt =
        dashboard.emergency.lastEvent?.createdAt ?? 'لا يوجد سجل';

    final filesCount = dashboard.medicalFiles.count;

    final bloodGroup = profile?.bloodGroup ?? 'غير محددة';
    final gender = profile?.gender == 'male'
        ? 'ذكر'
        : profile?.gender == 'female'
            ? 'أنثى'
            : 'غير محدد';
    final dateOfBirth = profile?.dateOfBirth ?? 'غير محدد';
    final height =
        profile?.heightCm != null ? '${profile!.heightCm} سم' : 'غير محدد';
    final weight =
        profile?.weightKg != null ? '${profile!.weightKg} كغ' : 'غير محدد';

  final emergenciesAsync = ref.watch(
  guardianPatientEmergenciesProvider(patient.id),
);

final hasUnreadEmergency = emergenciesAsync.maybeWhen(
  data: (events) => events.any((event) => !event.isRead),
  orElse: () => false,
);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً $guardianName',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                const Text(
                  'هذه لوحة التحكم الخاصة بالمريض المرتبط بحسابك.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 12),

                // شريط الطوارئ أعلى
                _EmergencyBanner(
                  emergencyCount: emergencyCount,
                  lastEmergencyAt: lastEmergencyAt,
                  hasUnreadEmergency: hasUnreadEmergency,
                  onTap: () async {
  await context.pushNamed(
    'guardianPatientEmergencies',
    pathParameters: {'id': patient.id},
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

Card(
  child: ListTile(
    leading: const CircleAvatar(
      child: Icon(Icons.badge_outlined),
    ),
    title: const Text('بطاقة المريض الصحية'),
    subtitle: const Text('عرض رمز QR والبيانات الطبية الأساسية'),
    trailing: const Icon(Icons.chevron_left_rounded),
    onTap: () => context.go('/guardian/card'),
  ),
),

const SizedBox(height: 12),

                // حالة اكتمال الملف
                Card(
                  child: ListTile(
                    leading: Icon(
                      isComplete
                          ? Icons.check_circle
                          : Icons.warning_amber_rounded,
                      color: isComplete ? Colors.green : Colors.orange,
                    ),
                    title: Text(
                      isComplete
                          ? 'الملف الطبي مكتمل'
                          : 'الملف الطبي غير مكتمل',
                      style: AppTextStyles.bodyMedium,
                    ),
                    subtitle: const Text(
                      'يمكنك تعديل/إكمال بيانات المريض (التاريخ المرضي، الأدوية، الحساسية...).',
                      style: AppTextStyles.bodySmall,
                    ),
trailing: TextButton(
  onPressed: () async {
    final wasUpdated = await context.pushNamed<bool>(
      'guardianPatientCompleteProfile',
      pathParameters: {
        'patientId': patient.id,
      },
    );

    debugPrint('wasUpdated = $wasUpdated');

    if (wasUpdated == true && context.mounted) {
      debugPrint('Refreshing dashboard for patient: ${patient.id}');
        ref.invalidate(
    guardianPatientDashboardProvider(patient.id),
      );
      ref.invalidate(
        guardianPatientDashboardWithNotifyProvider(patient.id),
      );
    }
  },
  child: const Text('إدارة الملف'),
),
                  ),
                ),

                const SizedBox(height: 12),

                // بيانات طبية أساسية
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'البيانات الطبية الأساسية',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _InfoChip(
                              label: 'تاريخ الميلاد',
                              value: dateOfBirth,
                              icon: Icons.cake,
                            ),
                            _InfoChip(
                              label: 'فصيلة الدم',
                              value: bloodGroup,
                              icon: Icons.bloodtype,
                            ),
                            _InfoChip(
                              label: 'الجنس',
                              value: gender,
                              icon: Icons.person,
                            ),
                            _InfoChip(
                              label: 'الطول',
                              value: height,
                              icon: Icons.height,
                            ),
                            _InfoChip(
                              label: 'الوزن',
                              value: weight,
                              icon: Icons.monitor_weight,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // كارت الملفات الطبية + زر عرض الملفات
                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.folder_shared,
                                color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'الملفات الطبية',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const Spacer(),
                            Text(
                              '$filesCount ملف',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
  context.pushNamed(
    'guardianPatientMedicalFiles',
    pathParameters: {'id': patient.id},
    extra: patient,
  );
},
                            child: const Text('عرض الملفات ورفع ملف جديد'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
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
    final hasData = emergencyCount > 0;
    final color = hasData ? Colors.red.shade50 : Colors.green.shade50;
    final iconColor = hasData ? Colors.red : Colors.green;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                hasData ? Colors.red.shade200 : Colors.green.shade200,
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.sos, color: iconColor, size: 28),
                if (hasUnreadEmergency)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حالة الطوارئ'),
                  const SizedBox(height: 2),
                  Text(
                    'عدد الحالات المسجلة: $emergencyCount',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    'آخر حالة: $lastEmergencyAt',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}