import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_emergencies_provider.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/providers/emergency_history_provider.dart';
class GuardianPatientEmergenciesScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const GuardianPatientEmergenciesScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<GuardianPatientEmergenciesScreen> createState() =>
      _GuardianPatientEmergenciesScreenState();
}

class _GuardianPatientEmergenciesScreenState
    extends ConsumerState<GuardianPatientEmergenciesScreen> {
  final Set<String> _readLocally = {};

  Future<void> _markAsRead(EmergencyEventItem event) async {
    if (event.isRead || _readLocally.contains(event.id)) return;

    setState(() => _readLocally.add(event.id));

    try {
      await markGuardianEmergencyAsRead(
        ref: ref,
        patientId: widget.patientId,
        eventId: event.id,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _readLocally.remove(event.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emergenciesAsync = ref.watch(
      guardianPatientEmergenciesProvider(widget.patientId),
    );

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
  title: Text('سجل الطوارئ '),
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
              final isRead = event.isRead || _readLocally.contains(event.id);
              final created = event.createdAt;
              final createdLabel =
                  '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} '
                  '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';

              final isResolved = event.status == 'resolved';
              final statusLabel = isResolved ? 'تمت المعالجة' : 'نشطة';
              final statusColor =
                  isResolved ? AppColors.success : AppColors.error;

              final guardians = event.guardians;

              return InkWell(
  borderRadius: BorderRadius.circular(16),
  onTap: () => _markAsRead(event),
  child: Stack(
    clipBehavior: Clip.none,
    children: [
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isRead
                ? Colors.transparent
                : AppColors.error.withValues(alpha: 0.45),
          ),
        ),
        elevation: isRead ? 1 : 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: statusColor,
                      fontWeight: isRead
                          ? FontWeight.w500
                          : FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    createdLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (event.locationName != null &&
                  event.locationName!.trim().isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.locationName!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              Row(
                children: [
                  Icon(
                    isRead
                        ? Icons.mark_email_read_outlined
                        : Icons.mark_email_unread_outlined,
                    size: 18,
                    color: isRead ? AppColors.grey700 : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isRead ? 'تمت القراءة' : 'غير مقروءة',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isRead ? AppColors.grey700 : AppColors.error,
                      fontWeight:
                          isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ],
              ),

              if (guardians.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'تم إشعار الأولياء (${guardians.length})',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                for (final g in guardians)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${g.name} - ${g.phone ?? 'بدون رقم مسجل'}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'لم يتم إشعار أي ولي أمر.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      if (!isRead)
        Positioned(
          top: -3,
          right: -3,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
    ],
  ),
);
            },
          );
        },
      ),
    );
  }
}