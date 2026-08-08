import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/features/guardian/data/datasources/guardian_medical_files_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/guardian/data/repositories/guardian_medical_files_repository_impl.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_medical_files_repository.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/medical_file.dart';

// datasource
final guardianMedicalFilesRemoteDataSourceProvider =
    Provider<GuardianMedicalFilesRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GuardianMedicalFilesRemoteDataSourceImpl(apiClient.dio);
});

// repository
final guardianMedicalFilesRepositoryProvider =
    Provider<GuardianMedicalFilesRepository>((ref) {
  final remote = ref.watch(guardianMedicalFilesRemoteDataSourceProvider);
  return GuardianMedicalFilesRepositoryImpl(remote: remote);
});

// FutureProvider.family
final guardianPatientMedicalFilesProvider =
    FutureProvider.family<List<MedicalFile>, String>((ref, patientId) {
  final repo = ref.watch(guardianMedicalFilesRepositoryProvider);
  return repo.getPatientMedicalFiles(patientId);
});