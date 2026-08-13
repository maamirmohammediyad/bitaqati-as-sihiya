import 'dart:async';

import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/providers/current_emergency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  bool _isLoading = false;
  Timer? _pollingTimer;
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();

    _lifecycleListener = AppLifecycleListener(
      onResume: _refreshEmergency,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshEmergency();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _lifecycleListener?.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshEmergency(),
    );
  }

  void _refreshEmergency() {
    ref.invalidate(currentEmergencyProvider);
  }

  Future<void> _confirmAndTriggerSos() async {
    if (_isLoading) return;

    final shouldSend = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 40,
            ),
            title: const Text('تأكيد نداء الطوارئ'),
            content: const Text(
              'سيتم إرسال نداء استغاثة مع موقعك الحالي إلى أولياء أمرك. '
              'لن تستطيع مغادرة شاشة الطوارئ إلا بعد إلغاء النداء وتأكيده '
              'أو بعد تسجيل وصولك من طرف المستشفى.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: const Icon(Icons.sos),
                label: const Text('إرسال النداء'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldSend) {
      await _triggerSos();
    }
  }

  Future<void> _triggerSos() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage('الرجاء تفعيل خدمة الموقع في الجهاز.');
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage('تم رفض صلاحية الموقع، لا يمكن إرسال موقعك.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final apiClient = ref.read(apiClientProvider);

      await apiClient.post(
        ApiConstants.sosTrigger,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      );

      _refreshEmergency();
    } catch (error) {
      _showMessage('تعذر إرسال نداء الطوارئ: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelSos(String eventId) async {
    if (_isLoading) return;

    final shouldCancel = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.cancel_outlined,
              color: AppColors.error,
              size: 40,
            ),
            title: const Text('إلغاء نداء الطوارئ؟'),
            content: const Text(
              'سيُحذف نداء الطوارئ نهائيًا، وسيُعاد فتح لوحة التحكم.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('رجوع'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('تأكيد الإلغاء'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldCancel) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = ref.read(apiClientProvider);

      await apiClient.delete(
        ApiConstants.sosCancel(eventId),
      );

      ref.invalidate(currentEmergencyProvider);

      if (mounted) {
        context.go('/patient/home');
      }
    } catch (error) {
      _showMessage('تعذر إلغاء نداء الطوارئ: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emergencyAsync = ref.watch(currentEmergencyProvider);

    return emergencyAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _ErrorState(
        error: error.toString(),
        onRetry: _refreshEmergency,
      ),
      data: (event) {
        if (event == null) {
          return _IdleSosView(
            isLoading: _isLoading,
            onTrigger: _confirmAndTriggerSos,
          );
        }

        if (event.status == 'checked_in') {
          return _CheckedInView(
            hospitalName: event.hospitalName,
          );
        }

        return _ActiveSosView(
          eventId: event.id,
          isLoading: _isLoading,
          onCancel: _cancelSos,
        );
      },
    );
  }
}

class _IdleSosView extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTrigger;

  const _IdleSosView({
    required this.isLoading,
    required this.onTrigger,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('الطوارئ'),
  leading: IconButton(
    tooltip: 'رجوع',
    icon: const BackButtonIcon(),
    onPressed: () {
      context.go('/patient/home');
    },
  ),
),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.error,
                  size: 92,
                ),
                const SizedBox(height: 24),
                Text(
                  'نداء طوارئ',
                  style: AppTextStyles.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'استخدم هذا الزر في الحالات الطارئة فقط. '
                  'سيتم إرسال موقعك إلى أولياء أمرك.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : onTrigger,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    icon: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.sos),
                    label: Text(
                      isLoading ? 'جارِ إرسال النداء...' : 'SOS',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                      ),
                    ),
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

class _ActiveSosView extends StatelessWidget {
  final String eventId;
  final bool isLoading;
  final ValueChanged<String> onCancel;

  const _ActiveSosView({
    required this.eventId,
    required this.isLoading,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'نداء الطوارئ نشط. يمكنك الإلغاء فقط بعد التأكيد أو انتظار تسجيل المستشفى.',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          title: const Text('نداء طوارئ نشط'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const _LockedEmergencyBanner(),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: eventId,
                    version: QrVersions.auto,
                    size: 230,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'اعرض هذا الرمز للموظف الطبي لتسجيل وصولك.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                const _EmergencyInformationCard(),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : () => onCancel(eventId),
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      isLoading ? 'جارِ الإلغاء...' : 'إلغاء نداء الطوارئ',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
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

class _LockedEmergencyBanner extends StatelessWidget {
  const _LockedEmergencyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'لقد ضغطت على زر الطوارئ. لا يمكن الخروج من هذه الشاشة إلا بإلغاء النداء وتأكيده أو بعد تسجيل وصولك من طرف المستشفى.',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyInformationCard extends StatelessWidget {
  const _EmergencyInformationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المعلومات الطبية', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            const _InfoRow(
              icon: Icons.warning_amber_outlined,
              title: 'الحساسيات',
              value: 'تُعرض عند مسح الرمز من نظام المستشفى',
            ),
            const Divider(),
            const _InfoRow(
              icon: Icons.medical_information_outlined,
              title: 'الأمراض المزمنة',
              value: 'تُعرض عند مسح الرمز من نظام المستشفى',
            ),
            const Divider(),
            const _InfoRow(
              icon: Icons.folder_outlined,
              title: 'الملفات الطبية',
              value: 'متاحة للموظف بعد مسح الرمز',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 3),
              Text(value, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckedInView extends StatelessWidget {
  final String? hospitalName;

  const _CheckedInView({
    required this.hospitalName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('تم تسجيل الوصول'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.success,
                size: 88,
              ),
              const SizedBox(height: 20),
              Text(
                'تم تسجيل وصولك بنجاح',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                hospitalName == null
                    ? 'تم تسجيل حالتك لدى المستشفى.'
                    : 'تم تسجيل حالتك لدى: $hospitalName',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => context.go('/patient/home'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('الرجوع إلى لوحة التحكم'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطوارئ')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.error,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'تعذر التحقق من حالة الطوارئ.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}