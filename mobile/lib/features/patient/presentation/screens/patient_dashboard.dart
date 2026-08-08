import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/common/widgets/glass_card.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/widgets/health_card.dart';

class PatientDashboard extends ConsumerStatefulWidget {
  const PatientDashboard({super.key});

  @override
  ConsumerState<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends ConsumerState<PatientDashboard> {
  bool _showWelcome = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showWelcome = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.home),
        ),
        body: Center(
          child: Text(
            localizations.unauthorized,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    final isProfileComplete = user.isProfileComplete;
    final userName = user.fullName;
    final nationalId = user.nationalId;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.home),
        actions: [
          // زر تغيير اللغة
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLanguage();
            },
          ),
          // إشعارات (جاهزة لاحقاً)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: فتح شاشة الإشعارات عند تجهيزها
              // context.go('/notifications');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.notificationSettings),
                ),
              );
            },
          ),
          // زر تسجيل الخروج بدلاً من الإعدادات الفارغة
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showWelcome) _WelcomeBanner(userName: userName),
            if (_showWelcome) const SizedBox(height: 12),

            // البطاقة الصحية في الأعلى
            GestureDetector(
              onTap: () {
                context.go('/patient/health-card');
              },
              child: HealthCardWidget(
                patientName: user.fullName,
                nationalId: user.nationalId,
                bloodType: user.bloodType ?? 'N/A',
                allergies: 'None',
                cardNumber: user.patientCode ?? 'N/A',
                validUntil: '12/2028',
              ),
            ),
            const SizedBox(height: 12),

            // Banner استكمال الملف الصحي
            if (!isProfileComplete) ...[
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              localizations.profileIncompleteMsg,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/patient/complete-profile');
                          },
                          child: Text(
                              localizations.completeProfileButtonLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 16),

            // بطاقة معلومات سريعة أعلى زر SOS
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${localizations.nationalIdLabel}: $nationalId',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      isProfileComplete
                          ? localizations.profileCompleteMsg
                          : localizations.profileIncompleteMsg,
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      localizations.todayHealthSummary,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // زر SOS
            ElevatedButton.icon(
              onPressed: () {
                context.push('/sos');
              },
              icon: const Icon(Icons.warning_amber_rounded, size: 28),
              label: Text(
                localizations.sos,
                style:
                    AppTextStyles.heading3.copyWith(color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // عنوان "ملخص الحالة"
            Text(
              localizations.todayHealthSummary,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            // إجراءات سريعة
            Text(
              localizations.quickActions,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
              children: [
                _QuickActionItem(
                  icon: Icons.warning_amber_rounded,
                  label: localizations.sos,
                  color: AppColors.error,
                  onTap: () {
                    context.push('/sos');
                  },
                ),
                _QuickActionItem(
                  icon: Icons.credit_card_rounded,
                  label: localizations.healthCard,
                  color: AppColors.primary,
                  onTap: () {
                    context.go('/patient/health-card');
                  },
                ),
                _QuickActionItem(
                  icon: Icons.qr_code_2_rounded,
                  label: localizations.qrCode, // تأكد أنه موجود في الترجمات، أو ضع نص ثابت مؤقتاً
                  color: AppColors.primary,
                  onTap: () {
                    context.go('/patient/qr');
                  },
                ),
                _QuickActionItem(
                  icon: Icons.folder_rounded,
                  label: localizations.medicalRecord,
                  color: AppColors.secondary,
                  onTap: () {
                    context.go('/patient/medical-record');
                  },
                ),
                _QuickActionItem(
                  icon: Icons.domain_rounded,
                  label: localizations.hospitals,
                  color: AppColors.success,
                  onTap: () {
                    context.go('/patient/hospitals');
                  },
                ),
                _QuickActionItem(
                  icon: Icons.assignment_ind_rounded,
                  label: localizations.completeProfileButtonLabel,
                  color: AppColors.primary,
                  onTap: () {
                    context.push('/patient/complete-profile');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // النشاط الأخير (placeholder للتسليم)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.recentActivity,
                  style: AppTextStyles.heading3,
                ),
                TextButton(
                  onPressed: () {
                    // لاحقاً: عرض كل النشاطات
                  },
                  child: Text(localizations.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: const [
                  _ActivityItem(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Checkup - Dr. Smith',
                    subtitle: '2 days ago',
                  ),
                  Divider(height: 1),
                  _ActivityItem(
                    icon: Icons.vaccines_outlined,
                    title: 'Vaccination scheduled',
                    subtitle: 'Next week',
                  ),
                  Divider(height: 1),
                  _ActivityItem(
                    icon: Icons.description_outlined,
                    title: 'Lab results available',
                    subtitle: 'Yesterday',
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

class _WelcomeBanner extends StatelessWidget {
  final String userName;
  const _WelcomeBanner({required this.userName});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.waving_hand_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${localizations.welcomeBack} $userName',
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.grey500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey400),
        ],
      ),
    );
  }
}