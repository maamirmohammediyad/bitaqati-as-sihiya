import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_repository.dart';
import 'package:bitaqati_as_sihiya/features/guardian/data/datasources/guardian_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_repository_impl.dart';
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
    FutureProvider.autoDispose.family<GuardianPatientDashboard, String>(
  (ref, patientId) {
    final repo = ref.watch(guardianRepositoryProvider);
    return repo.getPatientDashboard(patientId);
  },
);

final guardianPatientDashboardWithNotifyProvider =
    FutureProvider.autoDispose.family<GuardianPatientDashboard, String>(
  (ref, patientId) async {
    return ref.watch(
      guardianPatientDashboardProvider(patientId).future,
    );
  },
);

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

final guardianPatientQrTokenProvider = FutureProvider.autoDispose
    .family<String, String>((ref, patientId) async {
  final apiClient = ref.watch(apiClientProvider);

  final response = await apiClient.post(
    ApiConstants.guardianPatientQrToken(patientId),
  );

  final data = response.data['data'] as Map<String, dynamic>;
  return data['token'] as String;
});