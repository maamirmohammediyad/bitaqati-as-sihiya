import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/features/patient/domain/entities/patient_qr_dashboard.dart';

final patientQrDashboardProvider = FutureProvider.family
    .autoDispose<PatientQrDashboard, String>((ref, token) async {
  final apiClient = ref.read(apiClientProvider);

  final response = await apiClient.get('/patient/qr/$token');
  final data = response.data['data'] as Map<String, dynamic>;
  return PatientQrDashboard.fromJson(data);
});