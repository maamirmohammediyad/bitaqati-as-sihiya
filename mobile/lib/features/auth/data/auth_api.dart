import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/storage/secure_storage.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/models/auth_models.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthApi(apiClient.dio, secureStorage);
});

class AuthApi {
  AuthApi(this._dio, this._secureStorage);

  final Dio _dio;
  final SecureStorage _secureStorage;

  Future<AuthResponse> registerPatient({
    required String nationalId,
    required String firstName,
    required String lastName,
    String? phone,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register/patient',
      data: {
        'national_id': nationalId,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'password': password,
      },
    );

    final auth = AuthResponse.fromJson(response.data!);
    await _secureStorage.saveToken(auth.token);
    return auth;
  }

  Future<AuthResponse> registerGuardian({
    required String nationalId,
    required String name,
    String? email,
    required String phone,
    required String password,
    required String patientCode,
    required String relationship,
    bool? canAccessLocation,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register/guardian',
      data: {
        'national_id': nationalId,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'patient_code': patientCode,
        'relationship': relationship,
        'can_access_location': canAccessLocation,
      },
    );

    final auth = AuthResponse.fromJson(response.data!);
    await _secureStorage.saveToken(auth.token);
    return auth;
  }
}