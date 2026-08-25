import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

class StaffPatientMedicalFilesScreen extends ConsumerStatefulWidget {
  const StaffPatientMedicalFilesScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  ConsumerState<StaffPatientMedicalFilesScreen> createState() =>
      _StaffPatientMedicalFilesScreenState();
}

class _StaffPatientMedicalFilesScreenState
    extends ConsumerState<StaffPatientMedicalFilesScreen> {
  List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> _notes = [];
  Map<String, dynamic>? _record;

  bool _isLoading = true;
  bool _isUploading = false;
  bool _isAddingNote = false;
  String? _errorMessage;
  bool isSavingMedications = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final client = ref.read(apiClientProvider);

      final responses = await Future.wait([
        client.get<dynamic>(
          ApiConstants.hospitalPatientMedicalFiles(widget.patientId),
        ),
        client.get<dynamic>(
          ApiConstants.hospitalPatientMedicalRecord(widget.patientId),
        ),
        client.get<dynamic>(
          ApiConstants.hospitalPatientNotes(widget.patientId),
        ),
      ]);

      final filesBody = responses[0].data;
      final recordBody = responses[1].data;
      final notesBody = responses[2].data;

      if (filesBody is! Map || filesBody['data'] is! List) {
        throw const FormatException('صيغة ملفات الخادم غير صحيحة.');
      }

      if (recordBody is! Map || recordBody['data'] is! Map) {
        throw const FormatException('صيغة سجل المريض غير صحيحة.');
      }

      if (notesBody is! Map || notesBody['data'] is! List) {
        throw const FormatException('صيغة ملاحظات الخادم غير صحيحة.');
      }

      final files = (filesBody['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final notes = (notesBody['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _files = files;
        _notes = notes;
        _record = Map<String, dynamic>.from(recordBody['data'] as Map);
        _isLoading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _dioErrorMessage(error);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل سجل الملفات والملاحظات.';
      });
    }
  }

  String _dioErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final message = data['message']?.toString().trim();

      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstField = errors.values.first;

        if (firstField is List && firstField.isNotEmpty) {
          return firstField.first.toString();
        }
      }
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';
      case 403:
        return 'لا تملك صلاحية الوصول إلى بيانات هذا المريض.';
      case 404:
        return 'تعذر العثور على البيانات المطلوبة.';
      case 422:
        return 'تحقق من البيانات المدخلة أو الملف المختار.';
      default:
        return 'تعذر تنفيذ الطلب. تحقق من اتصال الشبكة.';
    }
  }

  int _asInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _value(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? fallback : text;
  }

  String _formatDateTime(dynamic value) {
    final raw = _value(value);

    if (raw.isEmpty) {
      return 'غير متوفر';
    }

    final date = DateTime.tryParse(raw);

    if (date == null) {
      return raw;
    }

    final local = date.toLocal();
    final now = DateTime.now();

    final isToday = now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;

    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);

    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'م' : 'ص';

    if (isToday) {
      return 'اليوم، $hour:$minute $period';
    }

    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')} - $hour:$minute $period';
  }

  String _formatSize(dynamic value) {
    final bytes = _asInt(value);

    if (bytes <= 0) return '';

    if (bytes < 1024) return '$bytes B';

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _fileTypeLabel(dynamic value) {
    switch (_value(value).toLowerCase()) {
      case 'analysis':
        return 'تحليل طبي';
      case 'prescription':
        return 'وصفة طبية';
      case 'report':
        return 'تقرير طبي';
      case 'xray':
        return 'أشعة أو صورة طبية';
      default:
        return 'ملف طبي';
    }
  }

  IconData _fileIcon(Map<String, dynamic> file) {
    final mimeType = _value(file['mime_type']).toLowerCase();
    final fileType = _value(file['file_type']).toLowerCase();

    if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf_outlined;
    }

    if (mimeType.contains('image')) {
      return Icons.image_outlined;
    }

    if (fileType == 'analysis') {
      return Icons.biotech_outlined;
    }

    if (fileType == 'prescription') {
      return Icons.receipt_long_outlined;
    }

    if (fileType == 'xray') {
      return Icons.medical_services_outlined;
    }

    return Icons.description_outlined;
  }

  Color _fileColor(BuildContext context, Map<String, dynamic> file) {
    final mimeType = _value(file['mime_type']).toLowerCase();
    final fileType = _value(file['file_type']).toLowerCase();

    if (mimeType.contains('pdf')) return Colors.red;
    if (mimeType.contains('image')) return Colors.orange;
    if (fileType == 'analysis') return Colors.teal;
    if (fileType == 'prescription') return Colors.deepPurple;
    if (fileType == 'xray') return Colors.indigo;

    return Theme.of(context).colorScheme.primary;
  }

Future<File> _saveDownloadedFile(Map<String, dynamic> file) async {
  final fileId = _value(file['id']);
  final originalName = _safeFileName(
    _value(
      file['original_name'],
      fallback: 'medical_file.pdf',
    ),
  );

  if (fileId.isEmpty) {
    throw StateError('تعذر تنزيل الملف: معرّف الملف غير موجود.');
  }

  final downloadPath = ApiConstants.hospitalPatientMedicalFileDownload(
    widget.patientId,
    fileId,
  );

  debugPrint('DOWNLOAD FILE MAP: $file');
  debugPrint('DOWNLOAD FILE ID: $fileId');
  debugPrint('DOWNLOAD URL: $downloadPath');

  final response = await ref.read(apiClientProvider).get<List<int>>(
        downloadPath,
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {
            'Accept': 'application/pdf,application/octet-stream,*/*',
          },
        ),
      );

  final bytes = response.data;

  if (bytes == null || bytes.isEmpty) {
    throw StateError('لم يستلم التطبيق محتوى الملف من الخادم.');
  }

  final directory = await getApplicationDocumentsDirectory();

  final downloadsDirectory = Directory(
    '${directory.path}/medical_files',
  );

  if (!await downloadsDirectory.exists()) {
    await downloadsDirectory.create(recursive: true);
  }

  final savedFile = File(
    '${downloadsDirectory.path}/'
    '${DateTime.now().millisecondsSinceEpoch}_$originalName',
  );

  await savedFile.writeAsBytes(bytes, flush: true);

  return savedFile;
}

  String _safeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return cleaned.isEmpty ? 'medical_file' : cleaned;
  }

  Future<void> _previewFile(Map<String, dynamic> file) async {
    try {
      _showBusyDialog('جارٍ تجهيز معاينة الملف...');
      final savedFile = await _saveDownloadedFile(file);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (savedFile == null) {
        throw StateError('تعذر حفظ الملف للمعاينة.');
      }

      final result = await OpenFilex.open(savedFile.path);

      if (!mounted) return;

      if (result.type != ResultType.done) {
        _showSnackBar(
          result.message.isEmpty
              ? 'تعذر فتح الملف على هذا الجهاز.'
              : result.message,
          isError: true,
        );
      }
    } on DioException catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar(_dioErrorMessage(error), isError: true);
    } catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar('تعذرت معاينة الملف: $error', isError: true);
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    try {
      _showBusyDialog('جارٍ تنزيل الملف...');
      final savedFile = await _saveDownloadedFile(file);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (savedFile == null) {
        throw StateError('تعذر حفظ الملف.');
      }

      _showSnackBar(
        'تم حفظ الملف في: ${savedFile.path}',
        isError: false,
      );
    } on DioException catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar(_dioErrorMessage(error), isError: true);
    } catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar('تعذر تنزيل الملف: $error', isError: true);
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> file) async {
    final fileId = _value(file['id']);

    if (fileId.isEmpty) {
      _showSnackBar('معرّف الملف غير صالح.', isError: true);
      return;
    }

    final confirmed = await _showConfirmationDialog(
      title: 'حذف الملف',
      message:
          'هل تريد حذف "${_value(file['original_name'], fallback: 'هذا الملف')}"؟ لا يمكن التراجع عن العملية.',
      confirmLabel: 'حذف',
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      _showBusyDialog('جارٍ حذف الملف...');

      await ref.read(apiClientProvider).delete<dynamic>(
            ApiConstants.hospitalPatientMedicalFileDelete(
              widget.patientId,
              fileId,
            ),
          );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar('تم حذف الملف بنجاح.', isError: false);
      await _loadData();
    } on DioException catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar(_dioErrorMessage(error), isError: true);
    }
  }

  Future<void> _showUploadSheet() async {
    final selected = await _pickFile();

    if (selected == null || !mounted) return;

    final descriptionController = TextEditingController();
    String fileType = 'other';

    final shouldUpload = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إضافة ملف طبي',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selected.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: fileType,
                    decoration: const InputDecoration(
                      labelText: 'نوع الملف',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'analysis',
                        child: Text('تحليل طبي'),
                      ),
                      DropdownMenuItem(
                        value: 'prescription',
                        child: Text('وصفة طبية'),
                      ),
                      DropdownMenuItem(
                        value: 'report',
                        child: Text('تقرير طبي'),
                      ),
                      DropdownMenuItem(
                        value: 'xray',
                        child: Text('أشعة أو صورة طبية'),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text('أخرى'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => fileType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'وصف الملف (اختياري)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          true,
                        );
                      },
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('رفع الملف'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (shouldUpload != true || !mounted) return;

    await _uploadFile(
      selected,
      fileType: fileType,
      description: descriptionController.text.trim(),
    );

    descriptionController.dispose();
  }

  Future<PlatformFile?> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final sizeLimit = 10 * 1024 * 1024;

      if (file.size > sizeLimit) {
        _showSnackBar('يجب ألا يتجاوز حجم الملف 10 MB.', isError: true);
        return null;
      }

      if (file.path == null || file.path!.isEmpty) {
        _showSnackBar('تعذر الوصول إلى مسار الملف المحدد.', isError: true);
        return null;
      }

      return file;
    } catch (_) {
      _showSnackBar('تعذر اختيار ملف من الجهاز.', isError: true);
      return null;
    }
  }

  Future<void> _uploadFile(
    PlatformFile file, {
    required String fileType,
    required String description,
  }) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
        'file_type': fileType,
        if (description.isNotEmpty) 'description': description,
      });

      await ref.read(apiClientProvider).postFormData<dynamic>(
            ApiConstants.hospitalPatientMedicalFiles(widget.patientId),
            data: formData,
          );

      if (!mounted) return;

      _showSnackBar('تم رفع الملف الطبي بنجاح.', isError: false);
      await _loadData();
    } on DioException catch (error) {
      _showSnackBar(_dioErrorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
Future<void> _showEditMedicationsDialog() async {
  final currentMedications = _value(_record?['medications']);

  final controller = TextEditingController(
    text: currentMedications,
  );

  String? medicationsToSave;

  final shouldSave = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('تعديل أدوية المريض'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            autofocus: true,
            minLines: 5,
            maxLines: 10,
            maxLength: 5000,
            decoration: const InputDecoration(
              hintText:
                  'مثال:\n'
                  'Metformin 500 mg — مرتان يوميًا بعد الأكل\n'
                  'Aspirin 81 mg — مرة يوميًا',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              medicationsToSave = controller.text.trim();
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('حفظ'),
          ),
        ],
      );
    },
  );

  controller.dispose();

  if (shouldSave != true || !mounted || medicationsToSave == null) {
    return;
  }

  await _saveMedications(medicationsToSave!);
}

Future<void> _saveMedications(String medications) async {
  if (isSavingMedications) return;

  setState(() => isSavingMedications = true);

  try {
    await ref.read(apiClientProvider).put<dynamic>(
          ApiConstants.hospitalPatientMedications(widget.patientId),
          data: {
            'medications': medications,
          },
        );

    if (!mounted) return;

    _showSnackBar(
      medications.isEmpty
          ? 'تم مسح أدوية المريض بنجاح.'
          : 'تم تحديث أدوية المريض بنجاح.',
      isError: false,
    );

    await _loadData();
  } on DioException catch (error) {
    if (!mounted) return;

    _showSnackBar(
      _dioErrorMessage(error),
      isError: true,
    );
  } finally {
    if (mounted) {
      setState(() => isSavingMedications = false);
    }
  }
}
Future<void> _showAddNoteDialog() async {
  final controller = TextEditingController();
  String? noteToSave;

  final shouldSave = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('إضافة ملاحظة'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          minLines: 3,
          maxLength: 2000,
          decoration: const InputDecoration(
            hintText: 'اكتب ملاحظتك الطبية هنا...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();

              if (text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى كتابة الملاحظة أولاً.'),
                  ),
                );
                return;
              }

              noteToSave = text;

              // أغلق الـdialog فقط؛ لا dispose للـcontroller هنا.
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('حفظ'),
          ),
        ],
      );
    },
  );

  // لا تتخلص من controller هنا.
  // سيُجمع تلقائيًا بعد انتهاء الدالة وعدم وجود مراجع له.
  if (shouldSave != true || noteToSave == null || !mounted) {
    return;
  }

  await _addNote(noteToSave!);
}
  Future<void> _addNote(String note) async {
    if (_isAddingNote) return;

    setState(() => _isAddingNote = true);

    try {
      await ref.read(apiClientProvider).post<dynamic>(
            ApiConstants.hospitalPatientNotes(widget.patientId),
            data: {'note': note},
          );

      if (!mounted) return;

      _showSnackBar('تمت إضافة الملاحظة بنجاح.', isError: false);
      await _loadData();
    } on DioException catch (error) {
      _showSnackBar(_dioErrorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isAddingNote = false);
      }
    }
  }

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    final noteId = _value(note['id']);

    if (noteId.isEmpty) {
      _showSnackBar('معرّف الملاحظة غير صالح.', isError: true);
      return;
    }

    final confirmed = await _showConfirmationDialog(
      title: 'حذف الملاحظة',
      message: 'هل تريد حذف هذه الملاحظة؟ لا يمكن التراجع عن العملية.',
      confirmLabel: 'حذف',
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      _showBusyDialog('جارٍ حذف الملاحظة...');

      await ref.read(apiClientProvider).delete<dynamic>(
            ApiConstants.hospitalPatientNoteDelete(
              widget.patientId,
              noteId,
            ),
          );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar('تم حذف الملاحظة بنجاح.', isError: false);
      await _loadData();
    } on DioException catch (error) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showSnackBar(_dioErrorMessage(error), isError: true);
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final color = isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary;

        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  void _showBusyDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملفات والملاحظات'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _isLoading ? null : _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _isUploading ? null : _showUploadSheet,
              icon: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_file_outlined),
              label: Text(_isUploading ? 'جارٍ الرفع' : 'إضافة ملف'),
            ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 140),
          Icon(
            Icons.cloud_off_outlined,
            size: 68,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      );
    }

    final record = _record ?? <String, dynamic>{};
    final latestScan = record['latest_scan'] is Map
        ? Map<String, dynamic>.from(record['latest_scan'] as Map)
        : <String, dynamic>{};

    final scannedBy = latestScan['scanned_by'] is Map
        ? Map<String, dynamic>.from(latestScan['scanned_by'] as Map)
        : <String, dynamic>{};
    final medications =
    record['medications']?.toString().trim() ?? '';
final canUpdateMedications =
    record['can_update_medications'] == true;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Text(
          widget.patientName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text('سجل الملفات والملاحظات الطبية'),
        const SizedBox(height: 16),
        GridView.count(
           crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
  childAspectRatio: 1.25,
          children: [
            _StatCard(
              icon: Icons.folder_copy_outlined,
              label: 'الملفات',
              value: '${_asInt(record['files_count'])}',
              color: Colors.indigo,
            ),
            _StatCard(
              icon: Icons.sticky_note_2_outlined,
              label: 'الملاحظات',
              value: '${_asInt(record['notes_count'])}',
              color: Colors.teal,
            ),
            _StatCard(
              icon: Icons.emergency_outlined,
              label: 'الطوارئ',
              value: '${_asInt(record['emergencies_count'])}',
              color: Colors.red,
            ),
            _StatCard(
              icon: Icons.qr_code_scanner_outlined,
              label: 'آخر مسح',
              value: latestScan.isEmpty
                  ? 'لا يوجد'
                  : _formatDateTime(latestScan['scanned_at']),
              color: Colors.deepPurple,
              smallValue: true,
            ),
          ],
        ),
        if (latestScan.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('أجرى آخر مسح'),
              subtitle: Text(
                _value(
                  scannedBy['name'],
                  fallback: 'موظف غير معروف',
                ),
              ),
              trailing: Text(
                _value(scannedBy['employee_code']),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),

Row(
  children: [
    const Expanded(
      child: Text(
        'الأدوية الحالية',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    // if (canUpdateMedications)
    //   IconButton(
    //     tooltip: 'تعديل الأدوية',
    //     onPressed: isSavingMedications
    // ? null
    // : _showEditMedicationsDialog,
    //     icon: isSavingMedications
    //         ? const SizedBox(
    //             width: 20,
    //             height: 20,
    //             child: CircularProgressIndicator(strokeWidth: 2),
    //           )
    //         : const Icon(Icons.edit_outlined),
    //   ),
  ],
),

const SizedBox(height: 10),

Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          child: Icon(Icons.medication_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            medications.isEmpty
                ? 'لا توجد أدوية مسجلة للمريض.'
                : medications,
            style: TextStyle(
              height: 1.5,
              color: medications.isEmpty
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
          ),
        ),
      ],
    ),
  ),
),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'الملفات الطبية',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text('${_files.length} ملف'),
          ],
        ),
        const SizedBox(height: 10),
        if (_files.isEmpty)
          _EmptyCard(
            icon: Icons.folder_open_outlined,
            text: 'لا توجد ملفات طبية مسجلة.',
          )
        else
          ..._files.map(_buildFileItem),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'الملاحظات المدونة',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: 'إضافة ملاحظة',
              onPressed: _isAddingNote ? null : _showAddNoteDialog,
              icon: _isAddingNote
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_comment_outlined),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_notes.isEmpty)
          _EmptyCard(
            icon: Icons.note_alt_outlined,
            text: 'لا توجد ملاحظات مدونة حتى الآن.',
          )
        else
          ..._notes.map(_buildNoteCard),
      ],
    );
  }

  Widget _buildFileItem(Map<String, dynamic> file) {
    final color = _fileColor(context, file);
    final size = _formatSize(file['size_bytes']);
    final date = _formatDateTime(file['created_at']);

    final details = [
      _fileTypeLabel(file['file_type']),
      if (size.isNotEmpty) size,
      date,
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey('medical-file-${_value(file['id'])}'),
        background: _SwipeBackground(
          alignment: Alignment.centerRight,
          color: Colors.green,
          icon: Icons.download_rounded,
          label: 'تنزيل',
        ),
        secondaryBackground: _SwipeBackground(
          alignment: Alignment.centerLeft,
          color: Colors.red,
          icon: Icons.delete_outline_rounded,
          label: 'حذف',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            await _downloadFile(file);
            return false;
          }

          await _deleteFile(file);
          return false;
        },
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Icon(_fileIcon(file)),
            ),
            title: Text(
              _value(file['original_name'], fallback: 'ملف طبي'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_value(file['description']).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _value(file['description']),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.visibility_outlined),
            onTap: () => _previewFile(file),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final author = note['author'] is Map
        ? Map<String, dynamic>.from(note['author'] as Map)
        : <String, dynamic>{};

    final canDelete = note['can_delete'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  child: Icon(Icons.person_outline_rounded, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _value(author['name'], fallback: 'موظف المستشفى'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (canDelete)
                  IconButton(
                    tooltip: 'حذف الملاحظة',
                    onPressed: () => _deleteNote(note),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(_value(note['note'])),
            ),
            Text(
              _formatDateTime(note['created_at']),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.smallValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(
              value,
              maxLines: smallValue ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: smallValue ? 12 : 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(
              icon,
              size: 42,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isRight = alignment == Alignment.centerRight;

    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(
        right: isRight ? 24 : 0,
        left: isRight ? 0 : 24,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}