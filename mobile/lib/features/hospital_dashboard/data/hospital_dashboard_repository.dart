import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/network/api_client.dart';

import '../models/hospital_dashboard.dart';
import 'hospital_dashboard_service.dart';

final hospitalDashboardServiceProvider = Provider<HospitalDashboardService>(
  (ref) {
    return HospitalDashboardService(
      ref.watch(apiClientProvider),
    );
  },
);

final hospitalDashboardRepositoryProvider = Provider<HospitalDashboardRepository>(
  (ref) {
    return HospitalDashboardRepository(
      ref.watch(hospitalDashboardServiceProvider),
    );
  },
);

final hospitalDashboardProvider = FutureProvider<HospitalDashboard>((ref) {
  return ref.watch(hospitalDashboardRepositoryProvider).getDashboard();
});

class HospitalDashboardRepository {
  HospitalDashboardRepository(this._service);

  final HospitalDashboardService _service;

  Future<HospitalDashboard> getDashboard() {
    return _service.getDashboard();
  }
}