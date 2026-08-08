import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';

class MedicalRecordScreen extends ConsumerStatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  ConsumerState<MedicalRecordScreen> createState() =>
      _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends ConsumerState<MedicalRecordScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _chronicController = TextEditingController();
  final _allergiesController = TextEditingController();

  String? _selectedBloodGroup;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _chronicController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      // لاحقاً: استدعاء API لتحديث الملف الطبي

      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.checkAuth();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الملف الطبي بنجاح (تجريبي).'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الطبي'),
      ),
      body: user == null
          ? const Center(
              child: Text('لا يوجد مستخدم مسجّل حالياً.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // البيانات الأساسية
                  Text(
                    'البيانات الصحية الأساسية',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'الاسم الكامل',
                    value: user.fullName,
                  ),
                  _InfoRow(
                    label: 'الرقم الوطني',
                    value: user.nationalId,
                  ),
                  _InfoRow(
                    label: 'فصيلة الدم',
                    value: user.bloodType ?? 'غير محددة',
                  ),
                  _InfoRow(
                    label: 'تاريخ الميلاد',
                    value: user.dateOfBirth != null
                        ? '${user.dateOfBirth!.year}-${user.dateOfBirth!.month.toString().padLeft(2, '0')}-${user.dateOfBirth!.day.toString().padLeft(2, '0')}'
                        : 'غير محدد',
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'معلومات الحساب',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'البريد الإلكتروني',
                    value: user.email ?? 'غير مضاف',
                  ),
                  _InfoRow(
                    label: 'رقم الهاتف',
                    value: user.phone ?? 'غير مضاف',
                  ),
                  _InfoRow(
                    label: 'دور المستخدم',
                    value: user.role == 'patient' ? 'مريض' : user.role,
                  ),
                  _InfoRow(
                    label: 'حالة الملف الصحي',
                    value: user.isProfileComplete
                        ? 'مكتمل'
                        : 'غير مكتمل',
                  ),
                  if (user.patientCode != null) ...[
                    _InfoRow(
                      label: 'رقم البطاقة الصحية',
                      value: user.patientCode!,
                    ),
                  ],

                  const SizedBox(height: 32),

                  Text(
                    'حالياً هذه الشاشة تعرض بيانات ملفك الطبي والحساب.\n'
                    'لاحقاً سيتم إضافة نموذج لتعديل هذه البيانات وحفظها.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.grey600),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveProfile,
        child: const Icon(Icons.save),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.grey700),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}