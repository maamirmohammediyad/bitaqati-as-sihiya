import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

class StaffPatientDetailsScreen extends ConsumerStatefulWidget {
  const StaffPatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  ConsumerState<StaffPatientDetailsScreen> createState() =>
      _StaffPatientDetailsScreenState();
}

class _StaffPatientDetailsScreenState
    extends ConsumerState<StaffPatientDetailsScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> patientMedications = [];
  bool isLoadingMedications = false;
  @override
  @override
void initState() {
  super.initState();
  _loadPatientDetails();
  loadPatientMedications();
}

  Future<void> _loadPatientDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ref.read(apiClientProvider).get<dynamic>(
            '/hospital/patients/${Uri.encodeComponent(widget.patientId)}',
          );

      final body = response.data;

      if (body is! Map || body['data'] is! Map) {
        throw const FormatException('صيغة استجابة الخادم غير صحيحة.');
      }

      if (!mounted) return;

      setState(() {
        _data = Map<String, dynamic>.from(body['data'] as Map);
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
        _errorMessage = 'تعذر تحميل بيانات المريض.';
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
    }

    if (error.response?.statusCode == 401) {
      return 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }

    if (error.response?.statusCode == 403) {
      return 'لا يمكنك الوصول إلى بيانات هذا المريض قبل مسح رمز QR الخاص به.';
    }

    if (error.response?.statusCode == 404) {
      return 'لم يتم العثور على المريض.';
    }

    if (error.response?.statusCode == 422) {
      return 'تعذر معالجة الطلب. تحقق من البيانات المدخلة.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'انتهت مهلة الاتصال بالخادم.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالخادم. تحقق من الشبكة.';
    }

    return 'تعذر تحميل بيانات المريض.';
  }

  String _value(dynamic value, {String fallback = 'غير متوفر'}) {
    if (value == null) return fallback;

    if (value is List) {
      final values = value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty && item != 'null')
          .toList();

      return values.isEmpty ? fallback : values.join('، ');
    }

    if (value is Map) {
      final values = value.values
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty && item != 'null')
          .toList();

      return values.isEmpty ? fallback : values.join('، ');
    }

    final text = value.toString().trim();

    return text.isEmpty || text == 'null' ? fallback : text;
  }

  String _formatDate(dynamic value) {
    final raw = value?.toString().trim() ?? '';

    if (raw.isEmpty || raw == 'null') {
      return 'غير معروف';
    }

    final date = DateTime.tryParse(raw);

    if (date == null) return raw;

    final local = date.toLocal();
    final now = DateTime.now();

    final isToday = now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;

    if (isToday) {
      final hour = local.hour == 0
          ? 12
          : (local.hour > 12 ? local.hour - 12 : local.hour);

      final minute = local.minute.toString().padLeft(2, '0');
      final period = local.hour >= 12 ? 'م' : 'ص';

      return 'اليوم، $hour:$minute $period';
    }

    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }

  Future<void> _openMedicalFiles() async {
  if (_isLoading || _errorMessage != null) {
    return;
  }

  await context.push(
    '/staff/patients/${Uri.encodeComponent(widget.patientId)}/medical-files',
    extra: _patientName,
  );

  if (mounted) {
    _loadPatientDetails();
  }
}

Future<void> _openPatientMedications() async {
  if (_isLoading || _errorMessage != null) {
    return;
  }

  await context.push(
    '/staff/patients/${Uri.encodeComponent(widget.patientId)}/medications',
    extra: _patientName,
  );

  if (!mounted) return;

  await Future.wait([
    _loadPatientDetails(),
    loadPatientMedications(),
  ]);
}
  String get _patientName {
    final data = _data ?? <String, dynamic>{};

    final patient = data['patient'] is Map
        ? Map<String, dynamic>.from(data['patient'] as Map)
        : <String, dynamic>{};

    return _value(
      patient['name'],
      fallback: widget.patientName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات المريض'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _isLoading
    ? null
    : () async {
        await Future.wait([
          _loadPatientDetails(),
          loadPatientMedications(),
        ]);
      },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
  await Future.wait([
    _loadPatientDetails(),
    loadPatientMedications(),
  ]);
},
        child: _buildBody(),
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 140),
          Icon(
            Icons.error_outline_rounded,
            size: 64,
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
              onPressed: _loadPatientDetails,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      );
    }

    final data = _data ?? <String, dynamic>{};

    final patient = data['patient'] is Map
        ? Map<String, dynamic>.from(data['patient'] as Map)
        : <String, dynamic>{};

    final name = _value(
      patient['name'],
      fallback: widget.patientName,
    );

    final patientCode = _value(patient['patient_code']);
    final phone = _value(patient['phone']);
    final bloodGroup = _value(patient['blood_group']);
    final allergies = _value(patient['allergies']);
    final chronicDiseases = _value(patient['chronic_diseases']);
    final emergencyNotes = _value(patient['emergency_notes']);

    final scanCount = int.tryParse(
          data['scan_count']?.toString() ?? '0',
        ) ??
        0;

    final lastScannedAt = _formatDate(data['last_scanned_at']);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  child: Text(
                    name.isNotEmpty ? name.characters.first : 'م',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('الكود الصحي: $patientCode'),
                const SizedBox(height: 4),
                Text('رقم الهاتف: $phone'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.bloodtype_outlined,
                title: 'فصيلة الدم',
                value: bloodGroup,
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.medical_information_outlined,
                title: 'الحساسية',
                value: allergies,
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.health_and_safety_outlined,
                title: 'الأمراض المزمنة',
                value: chronicDiseases,
              ),
              const Divider(height: 1),
              const Divider(height: 1),
ListTile(
  leading: const Icon(Icons.medication_outlined),
  title: const Text('الأدوية الموصوفة'),
  subtitle: isLoadingMedications
      ? const Padding(
          padding: EdgeInsets.only(top: 8),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
      : patientMedications.isEmpty
          ? const Text('لا توجد أدوية مسجلة')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: patientMedications.map((item) {
                final medicationData = item['medication'];

                final medication = medicationData is Map
                    ? Map<String, dynamic>.from(medicationData)
                    : <String, dynamic>{};

                final medicationName = _value(
                  medication['name'],
                  fallback: 'دواء غير معروف',
                );

                final genericName = _value(
                  medication['generic_name'],
                );

                final dose = _value(item['dose']);
                final instructions = _value(item['instructions']);

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    [
                      medicationName,
                      if (genericName != '-') genericName,
                      if (dose != '-') 'الجرعة: $dose',
                      if (instructions != '-') instructions,
                    ].join(' — '),
                  ),
                );
              }).toList(),
            ),
  trailing: IconButton(
    tooltip: 'إدارة الأدوية',
    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
    onPressed: _openPatientMedications,
  ),
),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.note_alt_outlined,
                title: 'ملاحظات طبية طارئة',
                value: emergencyNotes,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'عدد مرات المسح',
                value: '$scanCount مرة',
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.access_time_rounded,
                title: 'آخر مسح',
                value: lastScannedAt,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
FilledButton.icon(
  onPressed: _openPatientMedications,
  icon: const Icon(Icons.medication_outlined),
  label: const Text('أدوية المريض'),
  style: FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
  ),
),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _openMedicalFiles,
          icon: const Icon(Icons.folder_shared_outlined),
          label: const Text('فتح الملفات الطبية'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
Future<void> loadPatientMedications() async {
  if (mounted) {
    setState(() => isLoadingMedications = true);
  }

  try {
    final response = await ref.read(apiClientProvider).get<dynamic>(
      '/hospital/patients/${Uri.encodeComponent(widget.patientId)}/medications',
    );

    final body = response.data;

    if (body is! Map || body['data'] is! List) {
      throw const FormatException('صيغة بيانات الأدوية غير صحيحة');
    }

    final items = (body['data'] as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    if (!mounted) return;

    setState(() {
      patientMedications = items;
      isLoadingMedications = false;
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      patientMedications = [];
      isLoadingMedications = false;
    });
  }
}
  
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}