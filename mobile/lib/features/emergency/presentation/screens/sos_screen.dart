import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/widgets/emergency_mode_banner.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/widgets/sos_button.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/screens/emergency_history_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/providers/sos_guardians_provider.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/providers/nearby_hospitals_provider.dart';
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  bool _isActivated = false;
  bool _isLoading = false;

Future<void> _triggerSos() async {
  if (_isLoading) return;

  setState(() {
    _isActivated = true;
    _isLoading = true;
  });

  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تفعيل خدمة الموقع في الجهاز')),
        );
      }
      setState(() => _isActivated = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض صلاحية الموقع، لا يمكن إرسال موقعك'),
          ),
        );
      }
      setState(() => _isActivated = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latitude = position.latitude;
    final longitude = position.longitude;

    final apiClient = ref.read(apiClientProvider);

    await apiClient.post(
      ApiConstants.sosTrigger, // مثلاً '/emergency/sos'
      data: {
        'latitude': latitude,
        'longitude': longitude,
        // لا نرسل location_name من الفرونت
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال نداء الاستغاثة مع موقعك')),
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isActivated = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال نداء الاستغاثة: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.sos),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (_isActivated)
            EmergencyModeBanner(
              message: localizations.emergencyMode,
              onDismiss: () {
                setState(() => _isActivated = false);
              },
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _isActivated
                        ? localizations.sosActivated
                        : localizations.sosTitle,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: _isActivated
                          ? AppColors.error
                          : AppColors.grey900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.sosDescription,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SosButton(
                      onPressed: _isLoading ? null : _triggerSos,
                      isActivated: _isActivated,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!_isActivated) ...[
  _StatusRow(
    icon: Icons.gps_fixed,
    label: localizations.gpsEnabled,
    isActive: true,
  ),
  const SizedBox(height: 12),

  // عدد أولياء الأمور الحقيقيين
  Consumer(
    builder: (context, ref, _) {
      final guardiansAsync = ref.watch(sosGuardiansProvider);

      return guardiansAsync.when(
        loading: () => _StatusRow(
          icon: Icons.people_outline,
          label: 'جارِ حساب أولياء الأمور...',
          isActive: true,
        ),
        error: (e, _) => _StatusRow(
          icon: Icons.people_outline,
          label: 'تعذّر تحميل أولياء الأمور',
          isActive: false,
        ),
        data: (guardians) {
          final count = guardians.length;
          final label = '$count ${localizations.guardiansNotified.toLowerCase()}';
          return _StatusRow(
            icon: Icons.people_outline,
            label: label,
            isActive: count > 0,
          );
        },
      );
    },
  ),

  const SizedBox(height: 12),

  // المستشفيات (سنجعلها حقيقية في الخطوة 2)
  Consumer(
    builder: (context, ref, _) {
      final nearbyHospitalsAsync = ref.watch(nearbyHospitalsCountProvider);

      return nearbyHospitalsAsync.when(
        loading: () => _StatusRow(
          icon: Icons.local_hospital_outlined,
          label: 'جارِ حساب المستشفيات القريبة...',
          isActive: true,
        ),
        error: (e, _) => _StatusRow(
          icon: Icons.local_hospital_outlined,
          label: 'تعذّر تحميل المستشفيات القريبة',
          isActive: false,
        ),
        data: (count) {
          final label =
              '$count ${localizations.nearbyHospitals.toLowerCase()}';
          return _StatusRow(
            icon: Icons.local_hospital_outlined,
            label: label,
            isActive: count > 0,
          );
        },
      );
    },
  ),
]else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            localizations.sosSending,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _isActivated = false);
                            },
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: AppColors.error,
                            ),
                            label: Text(
                              localizations.cancelSos,
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                          TextButton.icon(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmergencyHistoryScreen(),
      ),
    );
  },
  icon: const Icon(Icons.history, color: AppColors.primary),
  label: const Text('عرض سجل نداءات الطوارئ'),
),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                 Consumer(
  builder: (context, ref, _) {
    final guardiansAsync = ref.watch(sosGuardiansProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: guardiansAsync.when(
        loading: () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('جارِ تحميل أولياء الأمور...'),
          ],
        ),
        error: (e, _) => Text(
          'تعذّر تحميل أولياء الأمور.\n$e',
          style: AppTextStyles.bodySmall,
        ),
        data: (guardians) {
          if (guardians.isEmpty) {
            return Text(
              'لا يوجد أولياء مرتبطون بحسابك بعد.\nيمكنك إضافة ولي أمر من خلال الإعدادات.',
              style: AppTextStyles.bodySmall,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سيتم إشعار أولياء الأمور التاليين:',
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < guardians.length; i++) ...[
                _ContactTile(
                  name: guardians[i].name,
                  relation: guardians[i].relation ?? 'ولي أمر',
                  phone: guardians[i].phone ?? 'بدون رقم',
                ),
                if (i != guardians.length - 1)
                  const Divider(height: 1),
              ],
            ],
          );
        },
      ),
    );
  },
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.successLight
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? AppColors.success : AppColors.grey400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyLarge,
          ),
        ),
        Icon(
          isActive ? Icons.check_circle : Icons.error_outline,
          size: 18,
          color: isActive ? AppColors.success : AppColors.grey400,
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String relation;
  final String phone;

  const _ContactTile({
    required this.name,
    required this.relation,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryContainer,
            child: Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyLarge),
                Text('$relation - $phone', style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}