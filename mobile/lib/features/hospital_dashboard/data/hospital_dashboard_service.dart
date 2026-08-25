import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

import '../models/hospital_dashboard.dart';

class HospitalDashboardService {
  HospitalDashboardService(this._apiClient);

  final ApiClient _apiClient;

  Future<HospitalDashboard> getDashboard() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/hospital/dashboard',
    );

    final rawData = response.data;

    if (rawData == null) {
      throw const FormatException('استجابة لوحة التحكم فارغة.');
    }

    return HospitalDashboard.fromJson(rawData);
  }
}