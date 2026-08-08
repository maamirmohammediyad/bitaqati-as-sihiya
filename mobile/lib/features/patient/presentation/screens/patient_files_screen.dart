import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
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
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'تعذر تحميل الملفات الطبية.\n$e',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
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

        // createdAt: DateTime → نص منسق
        final createdAt = file.createdAt;
        final createdAtLabel = createdAt != null
            ? 'تاريخ الرفع: ${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
            : null;

        // fileType: String غير nullable عندك
        final type = (file.description?.trim().isNotEmpty ?? false)
            ? file.fileType
            : 'ملف طبي';

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
            createdAtLabel ?? type ?? 'ملف طبي',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () {
            // لاحقاً: فتح/تحميل الملف عبر storagePath أو URL
          },
        );
      },
    );
  }
}
