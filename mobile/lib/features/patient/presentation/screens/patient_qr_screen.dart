import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:bitaqati_as_sihiya/core/localization/app_localizations.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_colors.dart';
import 'package:bitaqati_as_sihiya/core/theme/app_text_styles.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_provider.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/providers/patient_qr_provider.dart';
import 'package:bitaqati_as_sihiya/features/patient/presentation/providers/patient_qr_dashboard_provider.dart';

class PatientQrScreen extends ConsumerWidget {
  const PatientQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final qrAsync = ref.watch(patientQrTokenProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.qrCode),
        ),
        body: Center(
          child: Text(
            localizations.unauthorized,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.qrCode),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: qrAsync.when(
          data: (qrToken) {
            final remainingMinutes =
    qrToken.expiresAt.difference(DateTime.now()).inMinutes;

final validityText = remainingMinutes > 0
    ? 'صالح لمدة $remainingMinutes دقيقة'
    : 'انتهت صلاحية هذا الكود، يرجى التحديث.';
debugPrint('QR TOKEN SENT TO WIDGET: ${qrToken.token}');
debugPrint('QR EXPIRES AT: ${qrToken.expiresAt.toIso8601String()}');
            final dashboardAsync =
                ref.watch(patientQrDashboardProvider(qrToken.token));

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // معلومات المريض الأساسية
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0]
                                  : '?',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${localizations.nationalIdLabel}: ${user.nationalId}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                if (user.patientCode != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${localizations.cardNumber}: ${user.patientCode}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                                if (user.bloodType != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${localizations.bloodType}: ${user.bloodType}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // بعد Card(...),

Align(
  alignment: Alignment.centerRight,
  child: TextButton.icon(
    onPressed: () {
      // إلى شاشة البطاقة الصحية
      context.pushNamed('patientHealthCard');
      // أو لو تحب نفس أسلوب HealthCardScreen:
      // context.go('/patient/health-card');
    },
    icon: const Icon(Icons.credit_card_rounded, size: 18),
    label: const Text('عرض البطاقة الصحية'),
  ),
),

const SizedBox(height: 24),
                  const SizedBox(height: 24),

                  // الكود نفسه
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.grey200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      
                      child: QrImageView(
                        data: qrToken.token,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      validityText,
                      style: AppTextStyles.caption,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // تعليمات سريعة
                  Text(
  'استخدام الكود الصحي',
  style: AppTextStyles.bodyMedium,
),
const SizedBox(height: 8),
Text(
  'يمكن للطاقم الطبي أو الولي أو الجهات الصحية مسح هذا الكود للوصول إلى معلوماتك الأساسية، ملخص الملفات الطبية، وبيانات الاتصال في حالات الطوارئ.',
  style: AppTextStyles.bodySmall,
),
                  const SizedBox(height: 24),

                  // ملخص الملف الصحي القادم من /patient/qr/{token}
                  dashboardAsync.when(
                    data: (dashboard) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // جهات الاتصال في الطوارئ
                        if (dashboard.emergencyContacts.isNotEmpty) ...[
                          Text(
                            'جهات الاتصال في الطوارئ',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 8),
                          ...dashboard.emergencyContacts.take(1).map(
                            (c) => Text(
                              '${c.fullName} – ${c.phone}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // الملفات الطبية
                        Text(
                          'الملفات الطبية',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'عدد الملفات: ${dashboard.medicalFiles.count}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        ...dashboard.medicalFiles.recent.take(3).map(
                          (f) => Text(
                            '• ${f.originalName}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            // اسم الروت عندك: patientMedicalRecord أو patientFiles
                            context.pushNamed('patientFiles');
                            // أو:
                            // context.pushNamed('patientMedicalRecord');
                          },
                          child: const Text('عرض كل الملفات'),
                        ),

                        const SizedBox(height: 24),

                        // المستشفيات
                        Text(
                          'مقدمو الخدمة الصحية',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        if (dashboard.hospitals.isEmpty)
                          Text(
                            'لا توجد مستشفيات مرتبطة حالياً.',
                            style: AppTextStyles.bodySmall,
                          )
                        else ...[
                          ...dashboard.hospitals.take(3).map(
                            (h) => Text(
                              '• ${h.name} ${h.city != null ? '(${h.city})' : ''}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // اسم الروت: patientHospitals
                              context.pushNamed('patientHospitals');
                            },
                            child: const Text('عرض جميع المستشفيات'),
                          ),
                        ],
                      ],
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
 'تعذر تحميل ملخص الملف الصحي، لكن لا يزال بإمكانك استخدام الكود.',  
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // زر تحديث التوكن
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.invalidate(patientQrTokenProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('تحديث الكود'),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تعذر تحميل الكود الصحي، يرجى المحاولة مرة أخرى.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.invalidate(patientQrTokenProvider);
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}