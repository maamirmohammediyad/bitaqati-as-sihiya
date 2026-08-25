import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

class StaffEmergencyDetailsScreen extends ConsumerStatefulWidget {
  final String emergencyId;

  const StaffEmergencyDetailsScreen({
    super.key,
    required this.emergencyId,
  });

  @override
  ConsumerState<StaffEmergencyDetailsScreen> createState() =>
      _StaffEmergencyDetailsScreenState();
}

class _StaffEmergencyDetailsScreenState
    extends ConsumerState<StaffEmergencyDetailsScreen> {
  Map<String, dynamic>? _emergency;
  bool _isLoading = true;
  bool _isResolving = false;
  String? _errorMessage;

  Dio get _dio => ref.read(apiClientProvider).dio;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadEmergencyDetails);
  }

  Future<void> _loadEmergencyDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await _dio.get(
        '/hospital/emergencies/${widget.emergencyId}',
      );

      final responseData = response.data;
      final dynamic data = responseData is Map ? responseData['data'] : null;

      if (data is! Map) {
        throw Exception('صيغة بيانات الحالة غير صحيحة.');
      }

      if (!mounted) return;

      setState(() {
        _emergency = Map<String, dynamic>.from(data);
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _dioErrorMessage(e);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر جلب تفاصيل الحالة الطارئة.';
      });
    }
  }

  Future<void> _resolveEmergency() async {
    if (_isResolving) return;

    final currentStatus = _value(
      _emergency?['status'],
      fallback: '',
    ).toLowerCase();

    if (currentStatus == 'resolved') {
      _showMessage('هذه الحالة تم حلها مسبقًا.', isError: true);
      return;
    }

    final resolutionNotes = await _showResolveDialog();

    if (resolutionNotes == null) return;

    if (!mounted) return;

    setState(() => _isResolving = true);

    try {
      await _dio.post(
        '/hospital/emergencies/${widget.emergencyId}/resolve',
        data: {
          if (resolutionNotes.trim().isNotEmpty)
            'resolution_notes': resolutionNotes.trim(),
        },
      );

      if (!mounted) return;

      _showMessage('تم حل الحالة الطارئة بنجاح.');
      await _loadEmergencyDetails();
    } on DioException catch (e) {
      if (!mounted) return;

      _showMessage(
        _dioErrorMessage(e),
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'تعذر إنهاء الحالة الطارئة.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }

Future<String?> _showResolveDialog() {
  return showDialog<String?>(
    context: context,
    builder: (dialogContext) {
      final controller = TextEditingController();

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('حل الحالة الطارئة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'هل أنت متأكد من إنهاء هذه الحالة؟ لا يمكن التراجع عن هذا الإجراء.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    minLines: 2,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات الحل (اختياري)',
                      hintText: 'اكتب ملاحظات إنهاء الحالة...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  final notes = controller.text.trim();

                  FocusScope.of(dialogContext).unfocus();

                  Navigator.of(dialogContext).pop(notes);
                },
                child: const Text('تأكيد الحل'),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _openMap() async {
    final location = _asMap(_emergency?['location']);

    final latitude = _asDouble(
      location?['latitude'] ?? _emergency?['latitude'],
    );

    final longitude = _asDouble(
      location?['longitude'] ?? _emergency?['longitude'],
    );

    if (latitude == null || longitude == null) {
      _showMessage('إحداثيات الموقع غير متوفرة.', isError: true);
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      _showMessage('تعذر فتح تطبيق الخرائط.', isError: true);
    }
  }

Future<void> _openMedicalFile(Map<String, dynamic> file) async {
  final patient = _asMap(_emergency?['patient']);

  final patientId = _value(patient?['id'], fallback: '');
  final fileId = _value(file['id'], fallback: '');

  if (patientId.isEmpty || fileId.isEmpty) {
    _showMessage('بيانات الملف غير مكتملة.', isError: true);
    return;
  }

  final originalName = _value(
    file['original_name'] ?? file['name'],
    fallback: 'medical_file.pdf',
  );

  try {
    _showMessage('جارٍ تجهيز الملف للعرض...');

    final response = await _dio.get<List<int>>(
      '/hospital/patients/$patientId/medical-files/$fileId/download',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    final bytes = response.data;

    if (bytes == null || bytes.isEmpty) {
      throw Exception('الملف فارغ أو تعذر تنزيله.');
    }

    final tempDirectory = await getTemporaryDirectory();

    final safeFileName = originalName.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );

    final filePath = '${tempDirectory.path}/$safeFileName';

    final localFile = File(filePath);
    await localFile.writeAsBytes(
      bytes,
      flush: true,
    );

    final result = await OpenFilex.open(filePath);

    if (result.type != ResultType.done && mounted) {
      _showMessage(
        'تعذر فتح الملف. تأكد من وجود تطبيق يدعم PDF أو نوع الملف.',
        isError: true,
      );
    }
  } on DioException catch (e) {
    _showMessage(
      _dioErrorMessage(e),
      isError: true,
    );
  } catch (_) {
    _showMessage(
      'تعذر تنزيل أو فتح الملف الطبي.',
      isError: true,
    );
  }
}

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    final error = e.error;

    if (error != null && error.toString().isNotEmpty) {
      final text = error.toString();

      if (!text.contains('Instance of')) {
        return text;
      }
    }

    switch (e.response?.statusCode) {
      case 401:
        return 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى.';
      case 403:
        return 'ليس لديك صلاحية لتنفيذ هذه العملية.';
      case 404:
        return 'الحالة الطارئة غير موجودة.';
      case 422:
        return 'لا يمكن تنفيذ العملية على الحالة الحالية.';
      case 500:
        return 'حدث خطأ في الخادم.';
      default:
        return 'تعذر الاتصال بالخادم. حاول مرة أخرى.';
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? Colors.red : Colors.green,
          content: Text(message),
        ),
      );
  }

  String _value(dynamic value, {String fallback = 'غير متوفر'}) {
    if (value == null) return fallback;

    final result = value.toString().trim();

    if (result.isEmpty || result.toLowerCase() == 'null') {
      return fallback;
    }

    return result;
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'غير متوفر';
    }

    final parsedDate = DateTime.tryParse(value.toString());

    if (parsedDate == null) {
      return value.toString();
    }

    final date = parsedDate.toLocal();

    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${date.year}/${twoDigits(date.month)}/${twoDigits(date.day)} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  String _formatFileSize(dynamic value) {
    final bytes = _asDouble(value);

    if (bytes == null || bytes <= 0) {
      return 'غير متوفر';
    }

    if (bytes < 1024) {
      return '${bytes.toStringAsFixed(0)} بايت';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'pending':
        return 'حالة طارئة نشطة';
      case 'checked_in':
      case 'checkedin':
        return 'تم تسجيل الوصول للمستشفى';
      case 'resolved':
        return 'تم حل الحالة';
      case 'cancelled':
      case 'canceled':
        return 'تم إلغاء الحالة';
      default:
        return status.isEmpty ? 'حالة غير معروفة' : status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'checked_in':
      case 'checkedin':
        return Colors.blue;
      case 'cancelled':
      case 'canceled':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Icons.check_circle_outline;
      case 'checked_in':
      case 'checkedin':
        return Icons.local_hospital_outlined;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الحالة الطارئة'),
          actions: [
            IconButton(
              tooltip: 'تحديث البيانات',
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadEmergencyDetails,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorView(_errorMessage!);
    }

    final emergency = _emergency;

    if (emergency == null) {
      return _buildErrorView('لا توجد بيانات للحالة الطارئة.');
    }

    final patient = _asMap(emergency['patient']);
    final location = _asMap(emergency['location']);
    final hospital = _asMap(emergency['hospital']);
    final checkIn = _asMap(emergency['check_in']);
    final resolution = _asMap(emergency['resolution']);
    final resolver = _asMap(resolution?['resolved_by']);

    final status = _value(emergency['status'], fallback: 'active');
    final color = _statusColor(status);
    final isResolved = status.toLowerCase() == 'resolved';

    final latitude = _asDouble(location?['latitude']);
    final longitude = _asDouble(location?['longitude']);
    final hasCoordinates = latitude != null && longitude != null;

    final patientName = _value(patient?['name']);
    final patientPhone = _value(patient?['phone']);
    final patientEmail = _value(patient?['email']);
    final nationalId = _value(patient?['national_id']);
    final patientCode = _value(patient?['patient_code']);
    final patientId = _value(patient?['id']);

    final medicalFiles = _asMapList(patient?['medical_files']);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadEmergencyDetails,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusCard(
              label: _statusLabel(status),
              color: color,
              icon: _statusIcon(status),
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'بيانات الحالة',
              icon: Icons.emergency_outlined,
              children: [
                _buildInfoTile(
                  icon: Icons.tag,
                  label: 'رقم الحالة',
                  value: _value(
                    emergency['id'],
                    fallback: widget.emergencyId,
                  ),
                ),
                _buildInfoTile(
                  icon: Icons.info_outline,
                  label: 'حالة الطوارئ',
                  value: _statusLabel(status),
                  valueColor: color,
                ),
                _buildInfoTile(
                  icon: Icons.access_time,
                  label: 'تاريخ الإنشاء',
                  value: _formatDate(emergency['created_at']),
                ),
                _buildInfoTile(
                  icon: Icons.update_outlined,
                  label: 'آخر تحديث',
                  value: _formatDate(emergency['updated_at']),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: 'بيانات المريض',
              icon: Icons.person_outline,
              children: [
                _buildInfoTile(
                  icon: Icons.person_outline,
                  label: 'اسم المريض',
                  value: patientName,
                ),
                _buildInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'رمز المريض',
                  value: patientCode,
                ),
                _buildInfoTile(
                  icon: Icons.credit_card_outlined,
                  label: 'رقم الهوية الوطنية',
                  value: nationalId,
                ),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'رقم الهاتف',
                  value: patientPhone,
                ),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  label: 'البريد الإلكتروني',
                  value: patientEmail,
                ),
                _buildInfoTile(
                  icon: Icons.perm_identity,
                  label: 'معرف المريض',
                  value: patientId,
                ),
                _buildInfoTile(
                  icon: Icons.cake_outlined,
                  label: 'تاريخ الميلاد',
                  value: _value(patient?['date_of_birth']),
                ),
                _buildInfoTile(
                  icon: Icons.wc_outlined,
                  label: 'الجنس',
                  value: _value(patient?['gender']),
                ),
                _buildInfoTile(
                  icon: Icons.height_outlined,
                  label: 'الطول',
                  value: patient?['height_cm'] == null
                      ? 'غير متوفر'
                      : '${_value(patient?['height_cm'])} سم',
                ),
                _buildInfoTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'الوزن',
                  value: patient?['weight_kg'] == null
                      ? 'غير متوفر'
                      : '${_value(patient?['weight_kg'])} كغ',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: 'المعلومات الطبية',
              icon: Icons.medical_information_outlined,
              children: [
                _buildInfoTile(
                  icon: Icons.bloodtype_outlined,
                  label: 'فصيلة الدم',
                  value: _value(patient?['blood_group']),
                  valueColor: Colors.red.shade700,
                ),
                _buildInfoTile(
                  icon: Icons.warning_amber_outlined,
                  label: 'الحساسية',
                  value: _value(patient?['allergies']),
                  valueColor: Colors.red.shade700,
                  multiline: true,
                ),
                _buildInfoTile(
                  icon: Icons.coronavirus_outlined,
                  label: 'الأمراض المزمنة',
                  value: _value(patient?['chronic_diseases']),
                  multiline: true,
                ),
                _buildInfoTile(
                  icon: Icons.medication_outlined,
                  label: 'الأدوية الحالية',
                  value: _value(patient?['medications']),
                  multiline: true,
                ),
                _buildInfoTile(
                  icon: Icons.note_alt_outlined,
                  label: 'ملاحظات الطوارئ',
                  value: _value(patient?['emergency_notes']),
                  multiline: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildMedicalFilesSection(medicalFiles),

            const SizedBox(height: 16),

            _buildSection(
              title: 'موقع الحالة',
              icon: Icons.location_on_outlined,
              children: [
                _buildInfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'العنوان',
                  value: _value(location?['location_name']),
                  multiline: true,
                ),
                _buildInfoTile(
                  icon: Icons.pin_drop_outlined,
                  label: 'خط العرض',
                  value: latitude?.toString() ?? 'غير متوفر',
                ),
                _buildInfoTile(
                  icon: Icons.pin_drop_outlined,
                  label: 'خط الطول',
                  value: longitude?.toString() ?? 'غير متوفر',
                ),
                if (hasCoordinates)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: OutlinedButton.icon(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('فتح الموقع في الخرائط'),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: 'بيانات المستشفى والاستجابة',
              icon: Icons.local_hospital_outlined,
              children: [
                _buildInfoTile(
                  icon: Icons.local_hospital_outlined,
                  label: 'المستشفى',
                  value: _value(hospital?['name']),
                ),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'هاتف المستشفى',
                  value: _value(hospital?['phone']),
                ),
                _buildInfoTile(
                  icon: Icons.location_city_outlined,
                  label: 'المدينة',
                  value: _value(hospital?['city']),
                ),
                _buildInfoTile(
                  icon: Icons.login_outlined,
                  label: 'وقت تسجيل الوصول',
                  value: _formatDate(checkIn?['checked_in_at']),
                ),
                _buildInfoTile(
                  icon: Icons.check_circle_outline,
                  label: 'وقت حل الحالة',
                  value: _formatDate(resolution?['resolved_at']),
                ),
                _buildInfoTile(
                  icon: Icons.person_outline,
                  label: 'تم الحل بواسطة',
                  value: _value(resolver?['name']),
                ),
                _buildInfoTile(
                  icon: Icons.note_alt_outlined,
                  label: 'ملاحظات الحل',
                  value: _value(resolution?['notes']),
                  multiline: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: isResolved ? Colors.grey : Colors.red,
              ),
              onPressed: isResolved || _isResolving
                  ? null
                  : _resolveEmergency,
              icon: _isResolving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                isResolved
                    ? 'تم حل الحالة'
                    : _isResolving
                        ? 'جارٍ حل الحالة...'
                        : 'تأكيد حل الحالة',
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalFilesSection(List<Map<String, dynamic>> files) {
    if (files.isEmpty) {
      return _buildSection(
        title: 'الملفات الطبية',
        icon: Icons.folder_open_outlined,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.folder_off_outlined),
                SizedBox(width: 12),
                Expanded(
                  child: Text('لا توجد ملفات طبية مسجلة لهذا المريض.'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return _buildSection(
      title: 'الملفات الطبية (${files.length})',
      icon: Icons.folder_open_outlined,
      children: files.map((file) {
        final fileName = _value(
          file['original_name'] ?? file['name'],
          fallback: 'ملف طبي',
        );

        final description = _value(
          file['description'],
          fallback: '',
        );

        final fileType = _value(
          file['file_type'],
          fallback: 'other',
        );

        return Column(
          children: [
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.description_outlined),
              ),
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [
                  'النوع: $fileType',
                  _formatFileSize(file['size_bytes']),
                  if (description.isNotEmpty) description,
                ].join(' • '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: 'تنزيل الملف',
                icon: const Icon(Icons.download_outlined),
                onPressed: () => _openMedicalFile(file),
              ),
            ),
            const Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: color.withOpacity(0.10),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 60,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: colors.primaryContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool multiline = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(label),
          subtitle: multiline
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    value,
                    style: TextStyle(color: valueColor),
                  ),
                )
              : null,
          trailing: multiline
              ? null
              : SizedBox(
                  width: 150,
                  child: Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: valueColor,
                      fontWeight: valueColor == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadEmergencyDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}