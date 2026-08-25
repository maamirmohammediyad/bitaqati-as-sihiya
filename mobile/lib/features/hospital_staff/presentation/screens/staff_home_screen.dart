import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/providers/hospital_staff_provider.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final hospital = user?.activeHospital;

    if (user == null || !user.isHealthWorker || hospital == null) {
      return const Scaffold(
        body: Center(child: Text('تعذر تحميل بيانات موظف المستشفى.')),
      );
    }

    final dashboardAsync = ref.watch(hospitalDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(hospital.name),
        actions: [
          IconButton(
            tooltip: 'تحديث البيانات',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(hospitalDashboardProvider);
            },
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                context.go('/staff/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
  try {
    ref.invalidate(hospitalDashboardProvider);
    await ref.read(hospitalDashboardProvider.future);
  } catch (_) {
    // تعرض الواجهة رسالة الخطأ عبر dashboardAsync.when(error: ...)
  }
},
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'مرحبًا، ${user.fullName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '${hospital.name} · ${_roleLabel(user.hospitalStaffRole)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 24),

            dashboardAsync.when(
              loading: () => const _DashboardLoading(),
              error: (error, _) => _DashboardError(
                message: _errorMessage(error),
                onRetry: () => ref.invalidate(hospitalDashboardProvider),
              ),
              data: (dashboard) => _DashboardStats(data: dashboard),
            ),

            const SizedBox(height: 28),

            Text(
              'الخدمات السريعة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            _StaffActionCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'مسح الكود الصحي',
              subtitle: 'عرض ملف المريض باستخدام رمز QR',
              onTap: () => context.push('/staff/scan-qr'),
            ),

            _StaffActionCard(
              icon: Icons.history_rounded,
              title: 'سجل المرضى الممسوحين',
              subtitle: 'مراجعة المرضى الذين تم الوصول إلى بياناتهم',
              onTap: () => context.push('/staff/scanned-patients'),
            ),

            if (user.canViewHospitalEmergencies)
              _StaffActionCard(
                icon: Icons.emergency_rounded,
                title: 'الحالات الطارئة',
                subtitle: 'عرض ومتابعة حالات الطوارئ بالمستشفى',
                onTap: () => context.push('/staff/emergencies'),
              ),

            if (user.hospitalStaffRole == 'doctor')
  _StaffActionCard(
    icon: Icons.medication_rounded,
    title: 'إدارة الأدوية',
    subtitle: 'إضافة وتعديل أدوية المستشفى والجرعات الموصى بها',
    onTap: () => context.push('/staff/medications'),
  ),
_StaffActionCard(
  icon: Icons.lock_outline_rounded,
  title: 'تغيير كلمة المرور',
  subtitle: 'تحديث كلمة مرور حسابك بشكل آمن',
  onTap: () => context.push('/staff/change-password'),
),
            if (user.hospitalStaffRole == 'admin')
              _StaffActionCard(
                icon: Icons.people_alt_rounded,
                title: 'إدارة الموظفين',
                subtitle: 'إضافة وتعديل حسابات العاملين بالمستشفى',
                onTap: () => context.push('/staff/employees'),
              ),
          ],
        ),
      ),
    );
  }

  String _errorMessage(Object error) {
    return 'تعذر تحميل إحصائيات المستشفى. اسحب للأسفل أو اضغط إعادة المحاولة.';
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'مدير المستشفى';
      case 'receptionist':
        return 'موظف استقبال';
      case 'doctor':
        return 'طبيب';
      case 'nurse':
        return 'ممرض';
      case 'staff':
        return 'موظف';
      default:
        return 'موظف صحي';
    }
  }
}

class _DashboardStats extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DashboardStats({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = _findStats(data);

    final activeEmergencies = _valueFor(stats, const [
      'active_emergencies',
      'open_emergencies',
      'emergencies_count',
    ]);

    return Card(
      elevation: 0,
      color: AppColors.error.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/staff/emergencies'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.error.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: AppColors.error,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحالات النشطة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text('اضغط لعرض ومتابعة حالات الطوارئ'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                activeEmergencies,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _findStats(Map<String, dynamic> source) {
    for (final key in const ['stats', 'statistics', 'summary']) {
      final value = source[key];

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return source;
  }

  String _valueFor(Map<String, dynamic> stats, List<String> keys) {
    for (final key in keys) {
      final value = stats[key];

      if (value != null) {
        return value.toString();
      }
    }

    return '0';
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 110,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
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

class _StaffActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StaffActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }
}
