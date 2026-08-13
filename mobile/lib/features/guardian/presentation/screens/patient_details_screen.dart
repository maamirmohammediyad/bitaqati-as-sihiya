import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_providers.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/widgets/patient_files_section.dart';

class PatientDetailsScreen extends ConsumerWidget {
  const PatientDetailsScreen({
    super.key,
    required this.patient,
  });

  final User patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(
      guardianPatientDashboardProvider(patient.id),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed('guardianHome');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'رجوع',
            onPressed: () => context.goNamed('guardianHome'),
          ),
          title: Text('ملف ${patient.fullName}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث البيانات',
              onPressed: () {
                ref.invalidate(
                  guardianPatientDashboardProvider(patient.id),
                );
              },
            ),
          ],
        ),
        body: dashboardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => _DashboardErrorView(
            error: error,
            onRetry: () {
              ref.invalidate(
                guardianPatientDashboardProvider(patient.id),
              );
            },
          ),
          data: (dashboard) => _PatientDetailsBody(
            patient: dashboard.patient,
            profile: dashboard.profile,
            emergency: dashboard.emergency,
            onEditProfile: () async {
              final wasUpdated = await context.pushNamed<bool>(
                'guardianPatientCompleteProfile',
                pathParameters: {
                  'patientId': patient.id,
                },
              );

              if (wasUpdated == true) {
                ref.invalidate(
                  guardianPatientDashboardProvider(patient.id),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _PatientDetailsBody extends StatelessWidget {
  const _PatientDetailsBody({
    required this.patient,
    required this.profile,
    required this.emergency,
    required this.onEditProfile,
  });

  final User patient;
  final PatientProfileSummary? profile;
  final EmergencySummary emergency;
  final Future<void> Function() onEditProfile;

  String _genderText(String? gender) {
    switch (gender) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return 'غير محدد';
    }
  }

  String _valueOrNotSpecified(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'غير محدد';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // التحديث اليدوي متاح من أيقونة التحديث في AppBar.
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'معلومات المريض',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(patient.fullName),
              subtitle: Text('الرقم الوطني: ${patient.nationalId}'),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الملف الطبي',
                style: AppTextStyles.heading3,
              ),
              OutlinedButton.icon(
                onPressed: () => onEditProfile(),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تعديل'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: profile == null
                  ? const Text('لا توجد بيانات ملف طبي للمريض.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileRow(
                          icon: Icons.cake_outlined,
                          label: 'تاريخ الميلاد',
                          value: _valueOrNotSpecified(profile!.dateOfBirth),
                        ),
                        _ProfileRow(
                          icon: Icons.person_outline,
                          label: 'الجنس',
                          value: _genderText(profile!.gender),
                        ),
                        _ProfileRow(
                          icon: Icons.bloodtype_outlined,
                          label: 'فصيلة الدم',
                          value: _valueOrNotSpecified(profile!.bloodGroup),
                        ),
                        _ProfileRow(
                          icon: Icons.height_outlined,
                          label: 'الطول',
                          value: profile!.heightCm == null
                              ? 'غير محدد'
                              : '${profile!.heightCm} سم',
                        ),
                        _ProfileRow(
                          icon: Icons.monitor_weight_outlined,
                          label: 'الوزن',
                          value: profile!.weightKg == null
                              ? 'غير محدد'
                              : '${profile!.weightKg} كغ',
                        ),
                        _ProfileRow(
                          icon: Icons.warning_amber_outlined,
                          label: 'الحساسية',
                          value: _valueOrNotSpecified(profile!.allergies),
                        ),
                        _ProfileRow(
                          icon: Icons.medical_information_outlined,
                          label: 'الأمراض المزمنة',
                          value: _valueOrNotSpecified(
                            profile!.chronicDiseases,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'سجل الطوارئ',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                emergency.count > 0
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
              ),
              title: Text('عدد حالات الطوارئ: ${emergency.count}'),
              subtitle: emergency.lastEvent == null
                  ? const Text('لا توجد حالات طوارئ مسجلة.')
                  : Text(
                      'آخر حالة: ${emergency.lastEvent!.status} - '
                      '${emergency.lastEvent!.createdAt ?? ''}',
                    ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'الملفات الطبية',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          PatientFilesSection(patientId: patient.id),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon),
      title: Text(label),
      trailing: Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'تعذر تحميل بيانات المريض',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}