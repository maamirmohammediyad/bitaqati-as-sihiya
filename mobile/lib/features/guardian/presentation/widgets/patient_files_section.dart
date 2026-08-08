// import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bitaqati_as_sihiya/core/utils/file_url_helper.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_medical_files_provider.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/medical_file.dart';

class PatientFilesSection extends ConsumerWidget {
  const PatientFilesSection({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFiles = ref.watch(guardianPatientMedicalFilesProvider(patientId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        asyncFiles.when(
          data: (files) => _buildFilesList(context, files),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text(
            'حدث خطأ أثناء تحميل الملفات الطبية.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            await _pickAndUploadFile(context, ref);
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('رفع ملف جديد'),
        ),
      ],
    );
  }

Future<void> _pickAndUploadFile(
    BuildContext context, WidgetRef ref) async {
  // 1) إعداد أنواع الملفات المسموحة
  final typeGroup = XTypeGroup(
    label: 'documents',
    extensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );

  // 2) فتح منتقي الملفات
  final XFile? xfile =
      await openFile(acceptedTypeGroups: [typeGroup]);

  if (xfile == null) {
    return; // المستخدم ألغى
  }

  // 3) تحويل XFile إلى File (على الموبايل)
  final file = File(xfile.path);

  // مثال: التحقق من الحجم (10MB)
  final fileSize = await file.length();
  if (fileSize > 10 * 1024 * 1024) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('حجم الملف أكبر من 10 ميغابايت')),
    );
    return;
  }

  try {
    final repo = ref.read(guardianMedicalFilesRepositoryProvider);

    final uploaded = await repo.uploadPatientMedicalFile(
      patientId: patientId,
      file: file,
      description: xfile.name,
      fileType: 'document',
    );

    ref.invalidate(guardianPatientMedicalFilesProvider(patientId));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفع الملف: ${uploaded.originalName}'),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل رفع الملف: $e')),
    );
  }
}
Future<void> _openFile(
  BuildContext context,
  MedicalFile file,
) async {
  final url = FileUrlHelper.toAbsoluteUrl(file.url);

  if (url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('رابط الملف غير متوفر'),
      ),
    );
    return;
  }

  final didLaunch = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );

  if (!context.mounted) return;

  if (!didLaunch) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تعذر فتح الملف'),
      ),
    );
  }
}
  Widget _buildFilesList(BuildContext context, List<MedicalFile> files) {
    if (files.isEmpty) {
      return const Text(
        'لا توجد ملفات طبية لهذا المريض.',
        style: AppTextStyles.bodyMedium,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final f = files[index];
        final createdAt = f.createdAt;

final dateText = createdAt == null
    ? 'غير محدد'
    : '${createdAt.year}-'
        '${createdAt.month.toString().padLeft(2, '0')}-'
        '${createdAt.day.toString().padLeft(2, '0')}';

final subtitleText =
    (f.description?.trim().isNotEmpty ?? false)
        ? f.description!
        : (f.mimeType ?? 'ملف طبي');

        return Card(
          child: ListTile(
  leading: const Icon(Icons.insert_drive_file_outlined),
  title: Text(f.originalName),
  subtitle: Text(
    subtitleText,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  ),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        dateText,
        style: AppTextStyles.caption,
      ),
      const SizedBox(width: 8),
      const Icon(Icons.open_in_new, size: 18),
    ],
  ),
  onTap: () => _openFile(context, f),
),
        );
      },
    );
  }
}