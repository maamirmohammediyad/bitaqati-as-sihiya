import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentEmergency {
  final String id;
  final String status;
  final String? hospitalName;

  const CurrentEmergency({
    required this.id,
    required this.status,
    this.hospitalName,
  });

  factory CurrentEmergency.fromJson(Map<String, dynamic> json) {
    final hospital = json['checked_in_hospital'];

    return CurrentEmergency(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      hospitalName: hospital is Map
          ? hospital['name']?.toString()
          : null,
    );
  }
}

final currentEmergencyProvider =
    FutureProvider<CurrentEmergency?>((ref) async {
  final apiClient = ref.read(apiClientProvider);

  final response = await apiClient.get(
    ApiConstants.emergencyCurrent,
  );

  final responseBody = response.data;

  if (responseBody is! Map) {
    return null;
  }

  final data = responseBody['data'];

  if (data is! Map) {
    return null;
  }

  return CurrentEmergency.fromJson(
    Map<String, dynamic>.from(data),
  );
});