import 'dart:io';

import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/medical_file.dart';

abstract class GuardianMedicalFilesRepository {
  Future<List<MedicalFile>> getPatientMedicalFiles(String patientId);

  Future<MedicalFile> uploadPatientMedicalFile({
    required String patientId,
    required File file,
    String? description,
    String? fileType,
  });
}