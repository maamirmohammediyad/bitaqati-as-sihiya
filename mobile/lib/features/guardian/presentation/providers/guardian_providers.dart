import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/features/guardian/data/datasources/guardian_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_repository.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_repository_impl.dart';

final guardianRemoteDataSourceProvider =
    Provider<GuardianRemoteDataSource>((ref) {
  final dio = ref.watch(apiClientProvider).dio;

  return GuardianRemoteDataSourceImpl(dio);
});

final guardianRepositoryProvider = Provider<GuardianRepository>((ref) {
  return GuardianRepositoryImpl(
    remoteDataSource: ref.watch(guardianRemoteDataSourceProvider),
  );
});

final guardianPatientDashboardProvider =
    FutureProvider.autoDispose.family<GuardianPatientDashboard, String>(
  (ref, patientId) async {
    return ref
        .watch(guardianRepositoryProvider)
        .getPatientDashboard(patientId);
  },
);