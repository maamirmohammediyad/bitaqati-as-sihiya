import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';

abstract class GuardianRepository {
  Future<GuardianPatientDashboard> getPatientDashboard(String patientId);
}