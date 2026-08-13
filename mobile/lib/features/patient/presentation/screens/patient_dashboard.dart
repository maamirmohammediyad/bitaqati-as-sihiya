import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/providers/current_emergency_provider.dart';

class PatientDashboard extends ConsumerStatefulWidget {
  const PatientDashboard({super.key});

  @override
  ConsumerState<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends ConsumerState<PatientDashboard> {
  bool _showWelcome = true;
  bool _hasHandledEmergencyRedirect = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  void _handleEmergencyRedirect(String? status) {
    if (_hasHandledEmergencyRedirect || !mounted) {
      return;
    }

    if (status != 'active' && status != 'checked_in') {
      return;
    }

    _hasHandledEmergencyRedirect = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (status == 'active') {
        context.go('/sos');
      } else if (status == 'checked_in') {
        context.go('/emergency/checked-in');
      }
    });
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();

    if (!mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentEmergencyAsync = ref.watch(currentEmergencyProvider);

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

    currentEmergencyAsync.whenData((event) {
      _handleEmergencyRedirect(event?.status);
    });

    final userName = user.fullName.trim().isEmpty
        ? 'المريض'
        : user.fullName.trim();

    final isProfileComplete = user.isProfileComplete;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.home),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تغيير اللغة',
            icon: const Icon(Icons.language_rounded),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLanguage();
            },
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentEmergencyProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showWelcome
                    ? Padding(
                        key: const ValueKey('welcome'),
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _WelcomeHeader(userName: userName),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('welcome-hidden'),
                      ),
              ),

              if (!isProfileComplete) ...[
                _CompleteProfileBanner(
                  onTap: () {
                    context.push('/patient/complete-profile');
                  },
                ),
                const SizedBox(height: 16),
              ],

              _SosButton(
                onPressed: () {
                  context.go('/sos');
                },
              ),
              const SizedBox(height: 28),

              Text(
                localizations.quickActions,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: [
                  _DashboardGridItem(
                    icon: Icons.health_and_safety_outlined,
                    label: 'بطاقتي الصحية',
                    description: isProfileComplete
                        ? 'عرض البطاقة الصحية'
                        : 'أكمل الملف لتفعيلها',
                    color: AppColors.primary,
                    isEnabled: isProfileComplete,
                    onTap: () {
                      context.go('/patient/health-card');
                    },
                  ),
                  _DashboardGridItem(
                    icon: Icons.qr_code_2_rounded,
                    label: localizations.qrCode,
                    description: isProfileComplete
                        ? 'عرض رمز الاستجابة السريع'
                        : 'أكمل الملف لتفعيله',
                    color: AppColors.secondary,
                    isEnabled: isProfileComplete,
                    onTap: () {
                      context.go('/patient/qr');
                    },
                  ),
                  _DashboardGridItem(
                    icon: Icons.folder_copy_outlined,
                    label: localizations.medicalRecord,
                    description: 'بياناتك وملفاتك الصحية',
                    color: AppColors.success,
                    isEnabled: true,
                    onTap: () {
                      context.go('/patient/medical-record');
                    },
                  ),
                  _DashboardGridItem(
                    icon: Icons.description_outlined,
                    label: 'ملفاتي الطبية',
                    description: 'عرض الفحوصات والتقارير',
                    color: const Color(0xFF8B5CF6),
                    isEnabled: true,
                    onTap: () {
                      context.push('/patient/files');
                    },
                  ),
                  _DashboardGridItem(
                    icon: Icons.local_hospital_outlined,
                    label: localizations.hospitals,
                    description: 'المستشفيات القريبة منك',
                    color: const Color(0xFF4E7DDB),
                    isEnabled: true,
                    onTap: () {
                      context.go('/patient/hospitals');
                    },
                  ),
                  _DashboardGridItem(
                    icon: Icons.history_rounded,
                    label: 'سجل الطوارئ',
                    description: 'الحالات السابقة',
                    color: const Color(0xFFB76E00),
                    isEnabled: true,
                    onTap: () {
                      context.push('/emergency/history');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _HelpCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'للطوارئ اضغط زر SOS وسيتم إرسال طلب المساعدة.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String userName;

  const _WelcomeHeader({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.waving_hand_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localizations.welcomeBack} $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 3),
              Text(
                'نتمنى لك يومًا صحيًا وآمنًا',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompleteProfileBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _CompleteProfileBanner({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF7E8),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFFFD890),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE1A8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.assignment_late_outlined,
                  color: Color(0xFFC77A00),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أكمل ملفك الصحي',
                      style: AppTextStyles.bodyLarge,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'أكمل بياناتك لتفعيل البطاقة الصحية ورمز QR.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFFC77A00),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SosButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'طلب مساعدة طارئة SOS',
      child: SizedBox(
        height: 70,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sos_rounded,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS — طلب مساعدة',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'للاستخدام في حالات الطوارئ فقط',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;

  const _DashboardGridItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isEnabled ? color : AppColors.grey500;

    final iconBackgroundColor = isEnabled
        ? color.withValues(alpha: 0.12)
        : AppColors.grey100;

    final cardColor = isEnabled
        ? Theme.of(context).colorScheme.surface
        : AppColors.grey100;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: isEnabled
          ? label
          : '$label غير متاح حتى يتم إكمال الملف الصحي',
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isEnabled ? AppColors.grey100 : AppColors.grey200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 25,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isEnabled
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.lock_outline_rounded,
                      size: isEnabled ? 16 : 20,
                      color: AppColors.grey500,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isEnabled ? null : AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: isEnabled
                        ? AppColors.grey700
                        : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final VoidCallback onTap;

  const _HelpCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey100,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'هل تحتاج إلى مساعدة؟ تعرّف على طريقة استخدام زر الطوارئ.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.grey500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}