import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/providers/hospital_staff_provider.dart';

class StaffScannedPatientsScreen extends ConsumerWidget {
  const StaffScannedPatientsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(hospitalScannedPatientsProvider);
    await ref.read(hospitalScannedPatientsProvider.future);
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  String _value(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? fallback : text;
  }

  String _firstLetter(String name) {
    final cleaned = name.trim();

    if (cleaned.isEmpty) {
      return 'م';
    }

    return cleaned.characters.first;
  }

  String _formatDate(dynamic value) {
    final rawDate = value?.toString().trim() ?? '';

    if (rawDate.isEmpty || rawDate == 'null') {
      return 'غير معروف';
    }

    final date = DateTime.tryParse(rawDate);

    if (date == null) {
      return rawDate;
    }

    final localDate = date.toLocal();
    final now = DateTime.now();

    final isToday =
        now.year == localDate.year &&
        now.month == localDate.month &&
        now.day == localDate.day;

    if (isToday) {
      final hour = localDate.hour == 0
          ? 12
          : (localDate.hour > 12 ? localDate.hour - 12 : localDate.hour);

      final minute = localDate.minute.toString().padLeft(2, '0');
      final period = localDate.hour >= 12 ? 'م' : 'ص';

      return 'اليوم، $hour:$minute $period';
    }

    return '${localDate.year}/${localDate.month.toString().padLeft(2, '0')}/${localDate.day.toString().padLeft(2, '0')}';
  }

  void _openPatient(BuildContext context, Map<String, dynamic> scanRecord) {
    final patient = _asMap(scanRecord['patient']) ?? scanRecord;

    final patientId = _value(
      patient['id'] ?? scanRecord['patient_id'],
      fallback: '',
    );

    final patientName = _value(
      patient['name'] ?? scanRecord['patient_name'],
      fallback: 'المريض',
    );

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر العثور على معرّف المريض.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.push(
      '/staff/patients/$patientId',
      extra: patientName,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scansAsync = ref.watch(hospitalScannedPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المرضى الممسوحون'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: scansAsync.isLoading ? null : () => _refresh(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: scansAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => _ErrorState(
            message: _errorMessage(error),
            onRetry: () => _refresh(ref),
          ),
          data: (scans) {
            if (scans.isEmpty) {
              return const _EmptyState();
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: scans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final scanRecord = scans[index];
                final patient = _asMap(scanRecord['patient']) ?? scanRecord;

                final name = _value(
                  patient['name'],
                  fallback: 'مريض بدون اسم',
                );

                final patientCode = _value(
                  patient['patient_code'],
                  fallback: '',
                );

                final bloodGroup = _value(
                  patient['blood_group'],
                  fallback: '',
                );

                final scannedAt =
    scanRecord['last_scanned_at'] ?? scanRecord['scanned_at'];
final scanCount = int.tryParse(
  scanRecord['scan_count']?.toString() ?? '0',
) ?? 0;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 25,
                      child: Text(
                        _firstLetter(name),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (patientCode.isNotEmpty)
                          Text('الكود الصحي: $patientCode'),
                        if (bloodGroup.isNotEmpty)
                          Text('فصيلة الدم: $bloodGroup'),
                        if (scanCount > 1)
                          Text('عدد مرات المسح: $scanCount'),
                        Text('تم المسح: ${_formatDate(scannedAt)}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () => _openPatient(context, scanRecord),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _errorMessage(Object error) {
    final text = error.toString();

    if (text.contains('UnauthorizedException') || text.contains('401')) {
      return 'انتهت جلسة الدخول. الرجاء تسجيل الدخول مرة أخرى.';
    }

    if (text.contains('NetworkConnectionException')) {
      return 'تعذر الاتصال بالخادم. تأكد من الشبكة وعنوان الـ API.';
    }

    if (text.contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.';
    }

    if (text.contains('NotFoundException') || text.contains('404')) {
      return 'مسار الخدمة غير موجود على الخادم.';
    }

    return 'تعذر تحميل قائمة المرضى الممسوحين. حاول مرة أخرى.';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: const [
        SizedBox(height: 150),
        Icon(
          Icons.qr_code_scanner_outlined,
          size: 72,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'لا يوجد مرضى تم مسحهم بعد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'سيظهر هنا كل مريض تم مسح رمز QR الخاص به بواسطة حسابك.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 140),
        Icon(
          Icons.error_outline_rounded,
          size: 64,
          color: Colors.red.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ),
      ],
    );
  }
}