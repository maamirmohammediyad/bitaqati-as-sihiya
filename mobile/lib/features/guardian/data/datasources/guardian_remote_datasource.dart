import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';

abstract class GuardianRemoteDataSource {
  Future<GuardianPatientDashboard> getPatientDashboard(String patientId);

  Future<void> uploadMedicalFile({
    required String patientId,
    required File file,
    required String fileType,
    String? description,
  });
}

class GuardianRemoteDataSourceImpl implements GuardianRemoteDataSource {
  GuardianRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<GuardianPatientDashboard> getPatientDashboard(
    String patientId,
  ) async {
    final response = await _dio.get(
      '/guardian/patient/$patientId/dashboard',
    );

    developer.log(
      'Guardian dashboard response: ${response.data}',
      name: 'GuardianRemoteDataSource',
    );

    final root = response.data as Map<String, dynamic>;
    final data = root['data'] as Map<String, dynamic>;

    return GuardianPatientDashboard.fromJson(data);
  }

  @override
  Future<void> uploadMedicalFile({
    required String patientId,
    required File file,
    required String fileType,
    String? description,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
      'file_type': fileType,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    });

    final response = await _dio.post(
      '/guardian/patient/$patientId/medical-files',
      data: formData,
    );

    developer.log(
      'Upload medical file response: ${response.data}',
      name: 'GuardianRemoteDataSource',
    );
  }
}