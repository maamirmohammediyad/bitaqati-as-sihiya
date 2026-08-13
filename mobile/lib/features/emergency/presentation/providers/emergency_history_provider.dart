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
  final bool isRead;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final List<GuardianInfo> guardians;

  EmergencyEventItem({
    required this.id,
    required this.status,
    required this.isRead,
    required this.createdAt,
    this.resolvedAt,
    this.locationName,
    this.latitude,
    this.longitude,
    this.guardians = const [],
  });

  factory EmergencyEventItem.fromJson(Map<String, dynamic> json) {
    final guardiansJson = json['notified_guardians'] as List<dynamic>? ?? [];

    return EmergencyEventItem(
      id: json['id'].toString(),
      status: json['status'] as String? ?? 'active',
      isRead: json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'] as String)
          : null,
      locationName: json['location_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
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
final rawData = response.data['data'];

final data = rawData is List
    ? rawData
    : const <dynamic>[];

  return data
    .whereType<Map>()
    .map(
      (item) => EmergencyEventItem.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
    .toList();
});