import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';

class GuardianInfo {
  final String id;
  final String name;
  final String? phone;
  final DateTime? notifiedAt;

  GuardianInfo({
    required this.id,
    required this.name,
    this.phone,
    this.notifiedAt,
  });

  factory GuardianInfo.fromJson(Map<String, dynamic> json) {
    return GuardianInfo(
      id: json['guardian_id']?.toString() ?? '',
      name: json['guardian_name'] as String? ?? '',
      phone: json['guardian_phone'] as String?,
      notifiedAt: json['notified_at'] != null
          ? DateTime.tryParse(json['notified_at'] as String)
          : null,
    );
  }
}

class EmergencyEventItem {
  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? locationName;
  final List<GuardianInfo> guardians;

  EmergencyEventItem({
    required this.id,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.locationName,
    this.guardians = const [],
  });

  factory EmergencyEventItem.fromJson(Map<String, dynamic> json) {
    final guardiansJson = json['notified_guardians'] as List<dynamic>? ?? [];

    return EmergencyEventItem(
      id: json['id'].toString(),
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      locationName: json['location_name'] as String?,
      guardians: guardiansJson
          .whereType<Map<String, dynamic>>()
          .map(GuardianInfo.fromJson)
          .toList(),
    );
  }
}

final emergencyHistoryProvider =
    FutureProvider<List<EmergencyEventItem>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  final response = await apiClient.get(ApiConstants.emergencyHistory);
  // Laravel يرجع: { data: [...], meta: {...} }
  final data = response.data['data'] as List<dynamic>? ?? [];

  return data
      .whereType<Map<String, dynamic>>()
      .map(EmergencyEventItem.fromJson)
      .toList();
});