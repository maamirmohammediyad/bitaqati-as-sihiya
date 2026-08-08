import 'dart:io';

import 'package:bitaqati_as_sihiya/features/guardian/data/datasources/guardian_medical_files_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/medical_file.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/repositories/guardian_medical_files_repository.dart';

class GuardianMedicalFilesRepositoryImpl
    implements GuardianMedicalFilesRepository {
  GuardianMedicalFilesRepositoryImpl({
    required this.remote,
  });

  final GuardianMedicalFilesRemoteDataSource remote;

  @override
  Future<List<MedicalFile>> getPatientMedicalFiles(String patientId) {
    return remote.getPatientMedicalFiles(patientId);
  }

  @override
  Future<MedicalFile> uploadPatientMedicalFile({
    required String patientId,
    required File file,
    String? description,
    String? fileType,
  }) {
    return remote.uploadPatientMedicalFile(
      patientId: patientId,
      file: file,
      description: description,
      fileType: fileType,
    );
  }
}