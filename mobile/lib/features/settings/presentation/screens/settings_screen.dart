import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey100),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    user?.fullName.isNotEmpty == true
                        ? user!.fullName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'User',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.role.toUpperCase() ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Settings
          _SectionTitle(localizations.theme),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.language_outlined,
                title: localizations.language,
                subtitle: localizations.arabic,
                trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 52),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: localizations.darkMode,
                trailing: Switch(
                  value: false,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About
          _SectionTitle(localizations.about),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: localizations.appVersion,
                trailing: Text(
                  '1.0.0',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ),
              const Divider(height: 1, indent: 52),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: localizations.privacyPolicy,
                trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 52),
              _SettingsTile(
                icon: Icons.article_outlined,
                title: localizations.termsOfService,
                trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 52),
              _SettingsTile(
                icon: Icons.star_outline,
                title: localizations.rateApp,
                trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 52),
              _SettingsTile(
                icon: Icons.share_outlined,
                title: localizations.shareApp,
                trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account Actions
          _SectionTitle(localizations.profile),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.edit_outlined,
                title: localizations.editProfile,
                trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 52),
              _SettingsTile(
                icon: Icons.logout_outlined,
                title: localizations.logout,
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Delete Account
          Center(
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context),
              child: Text(
                localizations.deleteAccount,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logout),
        content: Text(localizations.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(localizations.logout),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteAccount),
        content: Text(localizations.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.grey500,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.grey500).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.grey600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: titleColor ?? AppColors.grey800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
