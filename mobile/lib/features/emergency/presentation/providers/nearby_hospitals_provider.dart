import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';

final nearbyHospitalsCountProvider =
    FutureProvider<int>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  // التحقق من خدمة الموقع والصلاحيات
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return 0;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return 0;
  }

  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  final response = await apiClient.get(
    ApiConstants.nearbyHospitals,
    queryParameters: {
      'lat': position.latitude,
      'lng': position.longitude,
    },
  );

  print('NEARBY HOSPITALS RESPONSE: ${response.data}');


  final data = response.data;
  final count = data['count'] as int? ??
      (data['data'] as List<dynamic>? ?? []).length;
 print('NEARBY HOSPITALS COUNT: $count');
  return count;
});