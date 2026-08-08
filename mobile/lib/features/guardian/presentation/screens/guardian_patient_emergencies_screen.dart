import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_emergencies_provider.dart';

class GuardianPatientEmergenciesScreen extends ConsumerWidget {
  final String patientId;
  final String patientName;

  const GuardianPatientEmergenciesScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergenciesAsync =
        ref.watch(guardianPatientEmergenciesProvider(patientId));

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    tooltip: 'رجوع',
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      if (Navigator.canPop(context)) {
        context.pop();
      } else {
        context.go('/guardian/home');
      }
    },
  ),
  title: Text('سجل الطوارئ - $patientName'),
),
      body: emergenciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'تعذر تحميل سجل الطوارئ لهذا المريض.\n$e',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'لا توجد نداءات طوارئ مسجلة لهذا المريض.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final event = events[index];
              final created = event.createdAt;
              final createdLabel =
                  '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} '
                  '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';

              final isResolved = event.status == 'resolved';
              final statusLabel = isResolved ? 'تمت المعالجة' : 'نشطة';
              final statusColor =
                  isResolved ? AppColors.success : AppColors.error;

              final guardians = event.guardians;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // السطر العلوي: الحالة + الأيقونة + الوقت
                      Row(
                        children: [
                          Icon(
                            isResolved
                                ? Icons.check_circle_outline
                                : Icons.warning_amber_rounded,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: statusColor),
                          ),
                          const Spacer(),
                          Text(
                            createdLabel,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.grey700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // الموقع (إن وجد)
                      if (event.locationName != null &&
                          event.locationName!.isNotEmpty) ...[
                        Text(
                          'الموقع:',
                          style: AppTextStyles.bodySmall
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.locationName!,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // معلومات إشعار الأولياء
                      if (guardians.isNotEmpty) ...[
                        Text(
                          'تم إشعار الأولياء:',
                          style: AppTextStyles.bodySmall
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        for (final g in guardians)
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${g.name} - ${g.phone ?? 'بدون رقم مسجل'}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ],
                          ),
                      ] else
                        Text(
                          'لم يتم إشعار أي ولي أمر.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.grey700),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}