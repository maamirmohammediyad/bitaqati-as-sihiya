import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/features/hospital_staff/presentation/providers/hospital_staff_provider.dart';

class StaffEmergenciesScreen extends ConsumerWidget {
  const StaffEmergenciesScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(hospitalEmergenciesProvider);
    await ref.read(hospitalEmergenciesProvider.future);
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

  String _value(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty || text.toLowerCase() == 'null' ? fallback : text;
  }

  int _asInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(dynamic value) {
    final raw = value?.toString().trim() ?? '';

    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      return 'غير معروف';
    }

    final date = DateTime.tryParse(raw);

    if (date == null) return raw;

    final localDate = date.toLocal();
    final now = DateTime.now();

    final isToday = now.year == localDate.year &&
        now.month == localDate.month &&
        now.day == localDate.day;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    if (isToday) {
      final hour = localDate.hour == 0
          ? 12
          : localDate.hour > 12
              ? localDate.hour - 12
              : localDate.hour;

      final period = localDate.hour >= 12 ? 'م' : 'ص';

      return 'اليوم، $hour:${twoDigits(localDate.minute)} $period';
    }

    return '${localDate.year}/${twoDigits(localDate.month)}/${twoDigits(localDate.day)}'
        ' ${twoDigits(localDate.hour)}:${twoDigits(localDate.minute)}';
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'pending':
        return 'بانتظار الوصول';
      case 'checked_in':
      case 'checkedin':
        return 'تم تسجيل الوصول';
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
        return Icons.check_circle_outline_rounded;
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

  String _errorMessage(Object error) {
    final text = error.toString();

    if (text.contains('401') || text.contains('UnauthorizedException')) {
      return 'انتهت جلسة الدخول. يرجى تسجيل الدخول مجددًا.';
    }

    if (text.contains('403') || text.contains('ForbiddenException')) {
      return 'ليس لديك صلاحية للوصول إلى الحالات الطارئة.';
    }

    if (text.contains('404') || text.contains('NotFoundException')) {
      return 'مسار الحالات الطارئة غير موجود على الخادم.';
    }

    if (text.contains('NetworkConnectionException')) {
      return 'تعذر الاتصال بالخادم. تحقق من الشبكة.';
    }

    if (text.contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.';
    }

    return 'تعذر تحميل الحالات الطارئة. حاول مرة أخرى.';
  }

List<Map<String, dynamic>> _extractEmergencies(
  dynamic response, {
  required bool available,
}) {
  final responseRoot = _asMap(response) ?? <String, dynamic>{};

  // Laravel يعيد:
  // { "data": { "available_emergencies": {...}, "hospital_emergencies": {...} } }
  final root = _asMap(responseRoot['data']) ?? responseRoot;

  final key = available
      ? 'available_emergencies'
      : 'hospital_emergencies';

  final page = _asMap(root[key]) ?? <String, dynamic>{};

  return _asMapList(page['data']);
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergenciesAsync = ref.watch(hospitalEmergenciesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الحالات الطارئة'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: emergenciesAsync.isLoading
                  ? null
                  : () => _refresh(ref),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('مسح QR للطوارئ'),
          onPressed: () => context.push('/staff/emergency-scan'),
        ),
        body: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: emergenciesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => _ErrorState(
              message: _errorMessage(error),
              onRetry: () => _refresh(ref),
            ),
            data: (emergencies) {
final availableItems = _extractEmergencies(
  emergencies,
  available: true,
);

final hospitalItems = _extractEmergencies(
  emergencies,
  available: false,
);

final items = <Map<String, dynamic>>[
  ...availableItems,
  ...hospitalItems,
];

              if (items.isEmpty) {
                return const _EmptyState();
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final emergency = items[index];

                  return _EmergencyCard(
                    emergency: emergency,
                    asMap: _asMap,
                    value: _value,
                    asInt: _asInt,
                    formatDate: _formatDate,
                    statusLabel: _statusLabel,
                    statusColor: _statusColor,
                    statusIcon: _statusIcon,
                    onTap: () {
                      final id = _value(emergency['id'], fallback: '');

                      if (id.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تعذر العثور على رقم الحالة الطارئة.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      context.push(
                        '/staff/emergencies/${Uri.encodeComponent(id)}',
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final Map<String, dynamic> emergency;
  final Map<String, dynamic>? Function(dynamic value) asMap;
  final String Function(dynamic value, {String fallback}) value;
  final int Function(dynamic value) asInt;
  final String Function(dynamic value) formatDate;
  final String Function(String status) statusLabel;
  final Color Function(String status) statusColor;
  final IconData Function(String status) statusIcon;
  final VoidCallback onTap;

  const _EmergencyCard({
    required this.emergency,
    required this.asMap,
    required this.value,
    required this.asInt,
    required this.formatDate,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final patient = asMap(emergency['patient']) ?? <String, dynamic>{};
    final qrScan = asMap(emergency['qr_scan']) ?? <String, dynamic>{};
    final lastScannedBy = asMap(qrScan['last_scanned_by']);

    final patientName = value(
      patient['name'],
      fallback: 'مريض بدون اسم',
    );

    final patientCode = value(
      patient['patient_code'],
      fallback: '',
    );

    final bloodGroup = value(
      patient['blood_group'],
      fallback: '',
    );

    final status = value(
      emergency['status'],
      fallback: 'active',
    );

    final color = statusColor(status);
    final count = asInt(qrScan['scan_count']);
    final isPriority = emergency['priority'] == true || count > 0;

    final lastScannerName = value(
      lastScannedBy?['name'],
      fallback: '',
    );

    final lastScannedAt = qrScan['last_scanned_at'];
    final checkedInAt = emergency['checked_in_at'];

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isPriority ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPriority
              ? Colors.orange.withValues(alpha: 0.75)
              : Colors.transparent,
          width: isPriority ? 1.4 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(
                      statusIcon(status),
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: statusLabel(status),
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (isPriority) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.priority_high_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'أولوية: تم التحقق من المريض عبر QR سابقًا',
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (patientCode.isNotEmpty)
                    _InfoLabel(
                      icon: Icons.badge_outlined,
                      text: 'الكود: $patientCode',
                    ),
                  if (bloodGroup.isNotEmpty)
                    _InfoLabel(
                      icon: Icons.bloodtype_outlined,
                      text: 'فصيلة الدم: $bloodGroup',
                      color: Colors.red.shade700,
                    ),
                  _InfoLabel(
                    icon: Icons.access_time_rounded,
                    text: 'الطوارئ: ${formatDate(emergency['created_at'])}',
                  ),
                  if (checkedInAt != null)
                    _InfoLabel(
                      icon: Icons.login_rounded,
                      text: 'الوصول: ${formatDate(checkedInAt)}',
                      color: Colors.blue.shade700,
                    ),
                ],
              ),
              if (count > 0) ...[
                const Divider(height: 24),
                _InfoLabel(
                  icon: Icons.qr_code_scanner_rounded,
                  text: 'عدد مرات المسح داخل المستشفى: $count',
                  color: Colors.orange.shade800,
                ),
                const SizedBox(height: 8),
                if (lastScannerName.isNotEmpty)
                  _InfoLabel(
                    icon: Icons.person_outline_rounded,
                    text: 'آخر مسح بواسطة: $lastScannerName',
                  ),
                if (lastScannedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _InfoLabel(
                      icon: Icons.history_rounded,
                      text: 'آخر مسح: ${formatDate(lastScannedAt)}',
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoLabel({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: itemColor),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: itemColor,
            ),
          ),
        ),
      ],
    );
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
          Icons.emergency_outlined,
          size: 72,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'لا توجد حالات طارئة حاليًا',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'ستظهر هنا الحالات النشطة والحالات التي استقبلها المستشفى.',
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
  final Future<void> Function() onRetry;

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