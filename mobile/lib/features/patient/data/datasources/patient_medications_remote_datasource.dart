import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

final patientMedicationsRemoteDataSourceProvider =
    Provider<PatientMedicationsRemoteDataSource>((ref) {
  return PatientMedicationsRemoteDataSource(
    ref.watch(apiClientProvider),
  );
});

class PatientMedicationsRemoteDataSource {
  const PatientMedicationsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getMyMedications() async {
    final response = await _apiClient.get<dynamic>(
      ApiConstants.patientMedications,
    );

    final body = response.data;

    if (body is! Map || body['data'] is! List) {
      throw const FormatException('صيغة بيانات الأدوية غير صحيحة.');
    }

    return (body['data'] as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}