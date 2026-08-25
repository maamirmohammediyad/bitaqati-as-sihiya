import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

final hospitalStaffRemoteDataSourceProvider =
    Provider<HospitalStaffRemoteDataSource>((ref) {
  return HospitalStaffRemoteDataSource(ref.watch(apiClientProvider));
});
class HospitalStaffRemoteDataSource {
  final ApiClient _apiClient;

  HospitalStaffRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _apiClient.get<dynamic>(
      ApiConstants.hospitalDashboard,
    );

    return _asMap(response.data);
  }

  Future<List<Map<String, dynamic>>> getMyScannedPatients() async {
    final response = await _apiClient.get<dynamic>(
      ApiConstants.hospitalMyScannedPatients,
    );

    return _asListFromResponse(response.data);
  }

  Future<Map<String, dynamic>> getPatientByQrToken(String token) async {
    final response = await _apiClient.get<dynamic>(
      ApiConstants.hospitalPatientQr(token),
    );

    return _asMap(response.data);
  }

Future<Map<String, dynamic>> getEmergencies() async {
  final response = await _apiClient.get<dynamic>(
    ApiConstants.hospitalEmergencies,
  );

  final body = response.data;

  if (body is Map<String, dynamic>) {
    return body;
  }

  if (body is Map) {
    return Map<String, dynamic>.from(body);
  }

  throw const FormatException('صيغة استجابة حالات الطوارئ غير صحيحة.');
}

  Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      return data is Map<String, dynamic> ? data : body;
    }

    throw const FormatException('صيغة استجابة الخادم غير صحيحة.');
  }

  List<Map<String, dynamic>> _asListFromResponse(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw const FormatException('صيغة استجابة الخادم غير صحيحة.');
    }

    final data = body['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }
}