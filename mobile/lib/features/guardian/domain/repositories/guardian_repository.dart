import 'dart:io';

import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';

abstract class GuardianRepository {
  Future<GuardianPatientDashboard> getPatientDashboard(String patientId);

  Future<void> uploadMedicalFile({
    required String patientId,
    required File file,
    required String fileType,
    String? description,
  });
}