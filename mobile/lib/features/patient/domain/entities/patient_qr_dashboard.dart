import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:bitaqati_as_sihiya/features/guardian/domain/entities/guardian_patient_dashboard.dart';

class PatientQrDashboard {
  final User patient;
  final PatientProfileSummary? profile;
  final EmergencySummary emergency;
  final MedicalFilesSummary medicalFiles;
  final QrSummary? qr;
  final List<EmergencyContactSummary> emergencyContacts;
  final List<HospitalSummary> hospitals;

  const PatientQrDashboard({
    required this.patient,
    required this.profile,
    required this.emergency,
    required this.medicalFiles,
    required this.qr,
    required this.emergencyContacts,
    required this.hospitals,
  });

  factory PatientQrDashboard.fromJson(Map<String, dynamic> json) {
    return PatientQrDashboard(
      patient: User.fromJson(json['patient'] as Map<String, dynamic>),
      profile: json['profile'] != null
          ? PatientProfileSummary.fromJson(
              json['profile'] as Map<String, dynamic>,
            )
          : null,
      emergency: EmergencySummary.fromJson(
        json['emergency'] as Map<String, dynamic>,
      ),
      medicalFiles: MedicalFilesSummary.fromJson(
        json['medical_files'] as Map<String, dynamic>,
      ),
      qr: json['qr'] != null
          ? QrSummary.fromJson(json['qr'] as Map<String, dynamic>)
          : null,
      emergencyContacts: (json['emergency_contacts'] as List<dynamic>? ?? [])
          .map(
            (e) => EmergencyContactSummary.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      hospitals: (json['hospitals'] as List<dynamic>? ?? [])
          .map(
            (e) => HospitalSummary.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}