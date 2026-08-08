import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/providers/emergency_history_provider.dart';

class EmergencyHistoryScreen extends ConsumerWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(emergencyHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل نداءات الطوارئ'),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'تعذر تحميل سجل الطوارئ.\n$e',
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
                  'لا توجد نداءات طوارئ مسجلة حتى الآن.',
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
              final statusLabel = isResolved ? 'تمت المعالجة' : 'نشط';
              final statusColor =
                  isResolved ? AppColors.success : AppColors.error;

              final guardians = event.guardians;

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isResolved
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_rounded,
                          color: statusColor,
                        ),
                        title: Text(
                          statusLabel,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: statusColor),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'وقت الإنشاء: $createdLabel',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.grey700),
                            ),
                            if (event.locationName != null &&
                                event.locationName!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                event.locationName!,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
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