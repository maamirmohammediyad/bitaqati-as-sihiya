import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/models/login_request.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/models/login_response.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/models/register_patient_response.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  Future<RegisterPatientResponse> registerPatient({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.registerPatient,
        data: {
          'national_id': nationalId,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'password': password,
        },
      );
      return RegisterPatientResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<LoginResponse> registerGuardian({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    String? patientCode,
    String? relationship,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.registerGuardian,
        data: {
          'national_id': nationalId,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'password': password,
          if (patientCode != null) 'patient_code': patientCode,
          if (relationship != null) 'relationship': relationship,
        },
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } on DioException {
      rethrow;
    }
  }
}