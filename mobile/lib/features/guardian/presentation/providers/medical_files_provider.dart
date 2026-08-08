import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart'; // عدّل المسار حسب مشروعك
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/medical_file.dart';

final patientMedicalFilesProvider =
    FutureProvider.family<List<MedicalFile>, String>((ref, patientId) async {
  final client = ref.read(apiClientProvider); // Dio أو http client عندك

  final response = await client.get('/guardian/patient/$patientId/medical-files');

  final data = response.data['data'] as List;

  return data
      .map((e) => MedicalFile.fromJson(e as Map<String, dynamic>))
      .toList();
});