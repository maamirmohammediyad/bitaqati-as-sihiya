import 'package:bitaqati_as_sihiya/features/medical_files/domain/entities/medical_file.dart';
import 'package:bitaqati_as_sihiya/features/patient/data/datasources/patient_medical_files_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/patient/domain/repositories/patient_medical_files_repository.dart';

class PatientMedicalFilesRepositoryImpl
    implements PatientMedicalFilesRepository {
  final PatientMedicalFilesRemoteDataSource remote;

  PatientMedicalFilesRepositoryImpl({required this.remote});

  @override
  Future<List<MedicalFile>> getMyMedicalFiles() {
    return remote.getMyMedicalFiles();
  }
}