import 'package:dio/dio.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/features/medical_files/domain/entities/medical_file.dart';

abstract class PatientMedicalFilesRemoteDataSource {
  Future<List<MedicalFile>> getMyMedicalFiles();
}

class PatientMedicalFilesRemoteDataSourceImpl
    implements PatientMedicalFilesRemoteDataSource {
  final Dio dio;

  PatientMedicalFilesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MedicalFile>> getMyMedicalFiles() async {
    final response = await dio.get(ApiConstants.patientMedicalFiles);

    final data = response.data['data'] as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => MedicalFile.fromJson(e))
        .toList();
  }
}