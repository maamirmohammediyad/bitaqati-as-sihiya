import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/features/hospital_staff/data/hospital_staff_remote_data_source.dart';

final hospitalDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(hospitalStaffRemoteDataSourceProvider).getDashboard();
});

final hospitalScannedPatientsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref
      .watch(hospitalStaffRemoteDataSourceProvider)
      .getMyScannedPatients();
});

final hospitalEmergenciesProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(hospitalStaffRemoteDataSourceProvider).getEmergencies();
});