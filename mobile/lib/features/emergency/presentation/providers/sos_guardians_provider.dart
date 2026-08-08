import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';

class SosGuardian {
  final String id;
  final String name;
  final String? phone;
  final String? relation;

  SosGuardian({
    required this.id,
    required this.name,
    this.phone,
    this.relation,
  });

  factory SosGuardian.fromJson(Map<String, dynamic> json) {
    return SosGuardian(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      relation: json['relation'] as String?,
    );
  }
}

final sosGuardiansProvider =
    FutureProvider<List<SosGuardian>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  final response = await apiClient.get(ApiConstants.emergencyGuardians);
  print('GUARDIANS RESPONSE: ${response.data}');

  final data = response.data['data'] as List<dynamic>? ?? [];

  return data
      .whereType<Map<String, dynamic>>()
      .map(SosGuardian.fromJson)
      .toList();
});