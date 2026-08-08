import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart'; // عدّل حسب مكان مزود Dio

class PatientQrToken {
  final String token;
  final DateTime expiresAt;

  PatientQrToken({required this.token, required this.expiresAt});

  factory PatientQrToken.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PatientQrToken(
      token: data['token'] as String,
      expiresAt: DateTime.parse(data['expires_at'] as String),
    );
  }
}

// مزود Future للحصول على التوكن من API
final patientQrTokenProvider =
    FutureProvider.autoDispose<PatientQrToken>((ref) async {
  final apiClient = ref.read(apiClientProvider); // أو اسم مزود Dio عندك

  final response = await apiClient.post('/patient/qr-token');
  return PatientQrToken.fromJson(response.data as Map<String, dynamic>);
});