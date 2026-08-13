import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PatientAccountScreen extends ConsumerWidget {
  const PatientAccountScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 38,
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName.substring(0, 1).toUpperCase()
                      : 'م',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 4),
            Text(
              'مريض',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('رقم الهاتف'),
                    subtitle: Text(user.phone ?? 'غير مضاف'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('البريد الإلكتروني'),
                    subtitle: Text(user.email ?? 'غير مضاف'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('كود المريض'),
                    subtitle: Text(user.patientCode ?? 'غير متوفر'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text('تغيير كلمة المرور'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () {
  context.push('/patient/change-password');
},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('تعديل معلومات الحساب'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () {
  context.push('/patient/edit-account');
},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();

                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}