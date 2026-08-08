import 'package:dio/dio.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';
import 'dart:developer' as developer;
abstract class GuardianRemoteDataSource {
  Future<GuardianPatientDashboard> getPatientDashboard(String patientId);
}

class GuardianRemoteDataSourceImpl implements GuardianRemoteDataSource {
  final Dio _dio;

  GuardianRemoteDataSourceImpl(this._dio);

  @override
  Future<GuardianPatientDashboard> getPatientDashboard(String patientId) async {
    final response = await _dio.get('/guardian/patient/$patientId/dashboard');
    developer.log(
      'Guardian dashboard response: ${response.data}',
      name: 'GuardianRemoteDataSource',
    );
     final root = response.data as Map<String, dynamic>;
    final data = root['data'] as Map<String, dynamic>;
    // return GuardianPatientDashboard.fromApiUserJson(userJson);
  return GuardianPatientDashboard.fromJson(data);
    }
  }
