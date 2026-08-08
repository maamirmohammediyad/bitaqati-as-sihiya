import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/features/emergency/presentation/providers/emergency_history_provider.dart';

// نفس EmergencyEventItem نعيد استخدامه

final guardianPatientEmergenciesProvider =
    FutureProvider.family<List<EmergencyEventItem>, String>(
        (ref, patientId) async {
  final apiClient = ref.watch(apiClientProvider);

  final response = await apiClient.get(
    ApiConstants.guardianPatientEmergencies(patientId),
  );

  final data = response.data['data'] as List<dynamic>? ?? [];

  return data
      .whereType<Map<String, dynamic>>()
      .map(EmergencyEventItem.fromJson)
      .toList();
});