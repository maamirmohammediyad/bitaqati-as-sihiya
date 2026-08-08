import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/features/medical_files/domain/entities/medical_file.dart';
import 'package:bitaqati_as_sihiya/features/patient/data/datasources/patient_medical_files_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/patient/data/repositories/patient_medical_files_repository_impl.dart';
import 'package:bitaqati_as_sihiya/features/patient/domain/repositories/patient_medical_files_repository.dart';

// datasource
final patientMedicalFilesRemoteDataSourceProvider =
    Provider<PatientMedicalFilesRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PatientMedicalFilesRemoteDataSourceImpl(apiClient.dio);
});

// repository
final patientMedicalFilesRepositoryProvider =
    Provider<PatientMedicalFilesRepository>((ref) {
  final remote = ref.watch(patientMedicalFilesRemoteDataSourceProvider);
  return PatientMedicalFilesRepositoryImpl(remote: remote);
});

// FutureProvider (لا يحتاج patientId لأن المستخدم الحالي هو المريض)
final myMedicalFilesProvider =
    FutureProvider<List<MedicalFile>>((ref) async {
  final repo = ref.watch(patientMedicalFilesRepositoryProvider);
  return repo.getMyMedicalFiles();
});