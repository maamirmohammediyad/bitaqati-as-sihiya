import 'dart:io';

import 'package:dio/dio.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/medical_file.dart';

abstract class GuardianMedicalFilesRemoteDataSource {
  Future<List<MedicalFile>> getPatientMedicalFiles(String patientId);

  Future<MedicalFile> uploadPatientMedicalFile({
    required String patientId,
    required File file,
    String? description,
    String? fileType,
  });
}

class GuardianMedicalFilesRemoteDataSourceImpl
    implements GuardianMedicalFilesRemoteDataSource {
  GuardianMedicalFilesRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<List<MedicalFile>> getPatientMedicalFiles(String patientId) async {
    final response = await dio.get(
      ApiConstants.guardianPatientMedicalFiles(patientId),
    );

    final responseData = response.data as Map<String, dynamic>;

    final filesJson = responseData['data'] as List<dynamic>? ?? [];

    return filesJson
        .map((item) => MedicalFile.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MedicalFile> uploadPatientMedicalFile({
    required String patientId,
    required File file,
    String? description,
    String? fileType,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'patient_id': patientId,
      if (description?.trim().isNotEmpty ?? false)
        'description': description!.trim(),
      if (fileType?.trim().isNotEmpty ?? false) 'file_type': fileType!.trim(),
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await dio.post(
      ApiConstants.guardianPatientMedicalFiles(patientId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final responseData = response.data as Map<String, dynamic>;
    final fileJson = responseData['data'] as Map<String, dynamic>;

    return MedicalFile.fromJson(fileJson);
  }
}
