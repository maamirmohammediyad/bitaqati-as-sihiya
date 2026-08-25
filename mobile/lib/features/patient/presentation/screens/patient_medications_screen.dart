import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/providers/patient_medications_provider.dart';

class PatientMedicationsScreen extends ConsumerWidget {
  const PatientMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(patientMedicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أدويتي'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(patientMedicationsProvider);
          await ref.read(patientMedicationsProvider.future);
        },
        child: medicationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => _ErrorView(
            message: _errorMessage(error),
            onRetry: () {
              ref.invalidate(patientMedicationsProvider);
            },
          ),
          data: (medications) {
            if (medications.isEmpty) {
              return const _EmptyMedicationsView();
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: medications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _MedicationCard(
                  medication: medications[index],
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _errorMessage(Object error) {
    final text = error.toString();

    if (text.contains('UnauthorizedException')) {
      return 'انتهت جلسة الدخول، يرجى تسجيل الدخول مجددًا.';
    }

    if (text.contains('NetworkConnectionException')) {
      return 'تعذر الاتصال بالخادم. تحقق من الإنترنت أو عنوان الخادم.';
    }

    if (text.contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.';
    }

    return 'تعذر تحميل قائمة الأدوية. حاول مرة أخرى.';
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.medication,
  });

  final Map<String, dynamic> medication;

  @override
  Widget build(BuildContext context) {
    final medicationData = medication['medication'];
    final medicationMap = medicationData is Map
        ? Map<String, dynamic>.from(medicationData)
        : <String, dynamic>{};

    final addedByData = medication['added_by'];
    final addedByMap = addedByData is Map
        ? Map<String, dynamic>.from(addedByData)
        : <String, dynamic>{};

    final name = _value(medicationMap['name'], 'دواء غير معروف');
    final genericName = _value(medicationMap['generic_name']);
    final dose = _value(medication['dose'], 'غير محددة');
    final instructions = _value(medication['instructions']);
    final prescribedBy = _value(addedByMap['name'], 'غير معروف');
    final date = _formatDate(medication['created_at']);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.grey100,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (genericName.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          genericName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _InfoRow(
              icon: Icons.straighten_rounded,
              label: 'الجرعة',
              value: dose,
            ),
            if (instructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.notes_rounded,
                label: 'التعليمات',
                value: instructions,
              ),
            ],
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: 'وُصف بواسطة',
              value: prescribedBy,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'تاريخ الوصفة',
              value: date,
            ),
          ],
        ),
      ),
    );
  }

  static String _value(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _formatDate(dynamic value) {
    final raw = value?.toString().trim() ?? '';

    if (raw.isEmpty) {
      return 'غير متاح';
    }

    final date = DateTime.tryParse(raw);

    if (date == null) {
      return raw;
    }

    final local = date.toLocal();

    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.grey700,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _EmptyMedicationsView extends StatelessWidget {
  const _EmptyMedicationsView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.medication_outlined,
          size: 72,
          color: AppColors.primary.withValues(alpha: 0.75),
        ),
        const SizedBox(height: 16),
        Text(
          'لا توجد أدوية موصوفة حاليًا',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 8),
        Text(
          'ستظهر هنا الأدوية التي يضيفها الطبيب أو موظفو المستشفى المخوّلون.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey700,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.error_outline_rounded,
          size: 64,
          color: AppColors.error,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ),
      ],
    );
  }
}