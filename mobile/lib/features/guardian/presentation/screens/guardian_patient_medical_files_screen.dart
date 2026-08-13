import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:bitaqati_as_sihiya/features/guardian/presentation/providers/guardian_providers.dart';

class GuardianPatientMedicalFilesScreen extends ConsumerStatefulWidget {
  const GuardianPatientMedicalFilesScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  ConsumerState<GuardianPatientMedicalFilesScreen> createState() =>
      _GuardianPatientMedicalFilesScreenState();
}

class _GuardianPatientMedicalFilesScreenState
    extends ConsumerState<GuardianPatientMedicalFilesScreen> {
  static const String _serverUrl = 'http://10.0.2.2:8000';

  bool _isUploading = false;

  String _buildFileUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return '$_serverUrl$path';
  }

  Future<void> _openFile(String path) async {
    final uri = Uri.parse(_buildFileUrl(path));

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الملف')),
      );
    }
  }

  Future<void> _showUploadSheet() async {
    final result = await showModalBottomSheet<_UploadData>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _UploadMedicalFileSheet(patientName: widget.patientName);
      },
    );

    if (result == null) return;

    await _uploadFile(result);
  }

  Future<void> _uploadFile(_UploadData uploadData) async {
    setState(() => _isUploading = true);

    try {
     
      // غيّر اسم الميثود/الـprovider أدناه فقط إذا كان مختلفًا في مشروعك.
      await ref.read(guardianRepositoryProvider).uploadMedicalFile(
            patientId: widget.patientId,
            file: File(uploadData.file.path!),
            fileType: uploadData.fileType.apiValue,
            description: uploadData.description,
          );
 debugPrint(
  'Uploading type: ${uploadData.fileType.apiValue}',
);
      ref.invalidate(
        guardianPatientDashboardProvider(widget.patientId),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الملف الطبي بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر رفع الملف: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(
      guardianPatientDashboardProvider(widget.patientId),
    );
  }

  IconData _fileIcon(String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType.contains('pdf')) {
      return Icons.picture_as_pdf_outlined;
    }

    if (normalizedType.contains('image') ||
        normalizedType.contains('jpg') ||
        normalizedType.contains('jpeg') ||
        normalizedType.contains('png')) {
      return Icons.image_outlined;
    }

    if (normalizedType.contains('analysis')) {
      return Icons.biotech_outlined;
    }

    if (normalizedType.contains('prescription')) {
      return Icons.receipt_long_outlined;
    }

    return Icons.description_outlined;
  }

  Color _fileColor(BuildContext context, String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType.contains('pdf')) {
      return Colors.red;
    }

    if (normalizedType.contains('analysis')) {
      return Colors.teal;
    }

    if (normalizedType.contains('prescription')) {
      return Colors.deepPurple;
    }

    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(
      guardianPatientDashboardProvider(widget.patientId),
    );

    return Scaffold(
      appBar: AppBar(
  title: const Text('الملفات الطبية'),
  centerTitle: true,
  leading: Navigator.canPop(context)
      ? IconButton(
          tooltip: 'رجوع',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        )
      : null,
  actions: [
    IconButton(
      tooltip: 'تحديث',
      onPressed: _isUploading ? null : _refresh,
      icon: const Icon(Icons.refresh_rounded),
    ),
  ],
),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _showUploadSheet,
        icon: _isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.upload_file_rounded),
        label: Text(_isUploading ? 'جارٍ الرفع...' : 'رفع ملف'),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          onRetry: _refresh,
        ),
        data: (dashboard) {
          final files = dashboard.medicalFiles.recent;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: files.isEmpty
                ? _EmptyFilesView(
                    patientName: widget.patientName,
                    onUpload: _isUploading ? null : _showUploadSheet,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: files.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _HeaderCard(
                          patientName: widget.patientName,
                          filesCount: files.length,
                        );
                      }

                      final file = files[index - 1];
final fileType = file.fileType ?? '';
final originalName = file.originalName;
final fileUrl = file.url ?? '';
final color = _fileColor(context, fileType);

                      return Card(
  clipBehavior: Clip.antiAlias,
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    leading: CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.12),
      foregroundColor: color,
      child: Icon(_fileIcon(fileType)),
    ),
    title: Text(
      originalName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        file.description?.trim().isNotEmpty == true
            ? file.description!
            : 'ملف طبي',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    trailing: const Icon(Icons.open_in_new_rounded),
    onTap: fileUrl.isEmpty ? null : () => _openFile(fileUrl),
  ),
);
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _UploadMedicalFileSheet extends StatefulWidget {
  const _UploadMedicalFileSheet({
    required this.patientName,
  });

  final String patientName;

  @override
  State<_UploadMedicalFileSheet> createState() =>
      _UploadMedicalFileSheetState();
}

class _UploadMedicalFileSheetState extends State<_UploadMedicalFileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  PlatformFile? _selectedFile;
  _MedicalFileType _selectedType = _MedicalFileType.analysis;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'doc',
        'docx',
      ],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _selectedFile = result.files.first;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null || _selectedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار ملف أولًا')),
      );
      return;
    }

    Navigator.of(context).pop(
      _UploadData(
        file: _selectedFile!,
        fileType: _selectedType,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, keyboardBottom + 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'رفع ملف طبي',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'للمريض: ${widget.patientName}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<_MedicalFileType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'نوع الملف',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _MedicalFileType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (type) {
                    if (type != null) {
                      setState(() => _selectedType = type);
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file_rounded),
                  label: Text(
                    _selectedFile == null
                        ? 'اختيار ملف'
                        : 'تغيير الملف',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                if (_selectedFile != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedFile!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_formatSize(_selectedFile!.size)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'وصف الملف (اختياري)',
                    hintText: 'مثال: تحليل دم شامل بتاريخ اليوم',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('رفع الملف'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.patientName,
    required this.filesCount,
  });

  final String patientName;
  final int filesCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.folder_shared_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ملفات $patientName',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '$filesCount ملف',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilesView extends StatelessWidget {
  const _EmptyFilesView({
    required this.patientName,
    required this.onUpload,
  });

  final String patientName;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.16),
        const Icon(
          Icons.folder_open_outlined,
          size: 76,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          'لا توجد ملفات طبية',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'يمكنك رفع تحليل، وصفة طبية، تقرير أو صورة للمريض $patientName.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onUpload,
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('رفع أول ملف'),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text('تعذر تحميل الملفات الطبية'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MedicalFileType {
  analysis('analysis', 'تحليل طبي'),
  prescription('prescription', 'وصفة طبية'),
  report('report', 'تقرير طبي'),
  xray('xray', 'أشعة أو صورة طبية'),
  other('other', 'ملف آخر');

  const _MedicalFileType(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class _UploadData {
  const _UploadData({
    required this.file,
    required this.fileType,
    required this.description,
  });

  final PlatformFile file;
  final _MedicalFileType fileType;
  final String description;
}