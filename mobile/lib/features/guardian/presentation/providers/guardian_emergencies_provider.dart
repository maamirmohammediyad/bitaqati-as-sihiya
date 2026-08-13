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

  final rawData = response.data['data'];

final data = rawData is List
    ? rawData
    : const <dynamic>[];

  return data
    .whereType<Map>()
    .map(
      (item) => EmergencyEventItem.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
    .toList();
});
final guardianEmergencyDetailProvider =
    FutureProvider.family<EmergencyEventItem, GuardianEmergencyParams>(
  (ref, params) async {
    final apiClient = ref.watch(apiClientProvider);

    final response = await apiClient.get(
      ApiConstants.guardianPatientEmergencyDetail(
        params.patientId,
        params.eventId,
      ),
    );

    final data = Map<String, dynamic>.from(
      response.data['data'] as Map,
    );

    return EmergencyEventItem.fromJson(data);
  },
);

class GuardianEmergencyParams {
  final String patientId;
  final String eventId;

  const GuardianEmergencyParams({
    required this.patientId,
    required this.eventId,
  });
}
Future<void> markGuardianEmergencyAsRead({
  required WidgetRef ref,
  required String patientId,
  required String eventId,
}) async {
  final apiClient = ref.read(apiClientProvider);

  await apiClient.post(
    ApiConstants.guardianPatientEmergencyRead(patientId, eventId),
  );

  ref.invalidate(guardianPatientEmergenciesProvider(patientId));
}

void refreshGuardianPatientEmergencies(
  WidgetRef ref,
  String patientId,
) {
  ref.invalidate(guardianPatientEmergenciesProvider(patientId));
}