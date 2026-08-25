import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/features/patient/data/datasources/patient_medications_remote_datasource.dart';

final patientMedicationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref
      .watch(patientMedicationsRemoteDataSourceProvider)
      .getMyMedications();
});