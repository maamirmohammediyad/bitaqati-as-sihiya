import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/medical_files/domain/entities/medical_file.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/providers/patient_medical_files_provider.dart';

class PatientFilesScreen extends ConsumerWidget {
  const PatientFilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(myMedicalFilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ملفاتي الطبية')),
      body: filesAsync.when(
        data: (files) => _FilesList(files: files),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 52,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'تعذر تحميل الملفات الطبية',
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'تحقق من اتصال الإنترنت ثم أعد المحاولة.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(myMedicalFilesProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilesList extends StatelessWidget {
  final List<MedicalFile> files;

  const _FilesList({required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'لا توجد ملفات طبية مضافة حتى الآن.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final file = files[index];

        final type = file.fileType?.trim().isNotEmpty == true
            ? file.fileType!
            : 'ملف طبي';

        final createdAt = file.createdAt;
        final createdAtLabel = createdAt != null
            ? 'تاريخ الرفع: '
                  '${createdAt.year}-'
                  '${createdAt.month.toString().padLeft(2, '0')}-'
                  '${createdAt.day.toString().padLeft(2, '0')}'
            : null;

        final details = [
          type,
          if (createdAtLabel != null) createdAtLabel,
        ].join(' • ');

        return ListTile(
          leading: const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            file.originalName,
            style: AppTextStyles.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            details,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () {
            // لاحقًا: فتح الملف أو تنزيله.
          },
        );
      },
    );
  }
}
