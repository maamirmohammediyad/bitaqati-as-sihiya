import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

class PatientQrToken {
  final String token;
  final DateTime expiresAt;

  PatientQrToken({required this.token, required this.expiresAt});

  factory PatientQrToken.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    if (rawData is! Map) {
      throw const FormatException('استجابة رمز QR غير صالحة');
    }

    final data = Map<String, dynamic>.from(rawData);
    final token = data['token']?.toString().trim() ?? '';
    final expiresAt = DateTime.tryParse(data['expires_at']?.toString() ?? '');

    if (token.isEmpty || expiresAt == null) {
      throw const FormatException('بيانات رمز QR غير مكتملة');
    }

    return PatientQrToken(token: token, expiresAt: expiresAt);
  }
}

final patientQrTokenProvider = FutureProvider.autoDispose<PatientQrToken>((
  ref,
) async {
  final apiClient = ref.read(apiClientProvider);

  final response = await apiClient.post('/patient/qr-token');

  if (response.data is! Map) {
    throw const FormatException('استجابة رمز QR غير صالحة');
  }

  return PatientQrToken.fromJson(
    Map<String, dynamic>.from(response.data as Map),
  );
});
