import 'package:bitaqati_as_sihiya/features/medical_files/domain/entities/medical_file.dart';

abstract class PatientMedicalFilesRepository {
  Future<List<MedicalFile>> getMyMedicalFiles();
}