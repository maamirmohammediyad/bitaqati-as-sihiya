import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_repository.dart';
import 'package:bitaqati_as_sihiya/features/guardian/data/datasources/guardian_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_repository_impl.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/main.dart'; // للوصول إلى flutterLocalNotificationsPlugin
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Provider للـ dataSource
final guardianRemoteDataSourceProvider = Provider<GuardianRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return GuardianRemoteDataSourceImpl(apiClient.dio); // <-- المهم هنا
  },
);

// Provider للـ repository
final guardianRepositoryProvider = Provider<GuardianRepository>(
  (ref) {
    final remote = ref.watch(guardianRemoteDataSourceProvider);
    return GuardianRepositoryImpl(remoteDataSource: remote);
  },
);

// FutureProvider.family لجلب Dashboard حسب patientId
final guardianPatientDashboardProvider =
// حالة وجود طوارئ غير مقروءة لكل مريض (حسب patientId)
  FutureProvider.family<GuardianPatientDashboard, String>((ref, patientId) {
  final repo = ref.watch(guardianRepositoryProvider);
  return repo.getPatientDashboard(patientId);
});
final unreadEmergencyProvider =
  StateProvider.family<bool, String>((ref, patientId) => false);
final guardianPatientDashboardWithNotifyProvider = FutureProvider.family<
    GuardianPatientDashboard, String>((ref, patientId) async {
  final dashboard =
      await ref.watch(guardianPatientDashboardProvider(patientId).future);

  final prevUnread =
      ref.read(unreadEmergencyProvider(patientId)); // القيمة السابقة
  final emergencyCount = dashboard.emergency.count;

  // لو كان عدد الطوارئ > 0 ولم نكن نعتبرها "مقروءة"، نرسل إشعار ونشغل النقطة
  if (emergencyCount > 0 && !prevUnread) {
    await _showEmergencyNotification(dashboard);
    ref.read(unreadEmergencyProvider(patientId).notifier).state = true;
  }

  return dashboard;
});

Future<void> _showEmergencyNotification(
    GuardianPatientDashboard dashboard) async {
  final patient = dashboard.patient;

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'emergency_channel',
    'Emergency Alerts',
    importance: Importance.max,
    priority: Priority.high,
  );

  final NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'حالة طوارئ جديدة',
    'تم تسجيل حالة طوارئ للمريض ${patient.fullName}',
    platformDetails,
    payload: 'emergency:${patient.id}',
  );
}