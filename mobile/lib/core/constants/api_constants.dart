class ApiConstants {
  ApiConstants._();

  /// Emulator: 10.0.2.2 يشير إلى localhost على جهاز التطوير.
  /// Production example: https://api.example.com
  static const serverUrl = 'http://192.168.1.40:8000';

  /// رابط Laravel API.
  static const baseUrl = '$serverUrl/api';

  /// الملفات العامة القادمة من Laravel storage.
  static const storageUrl = '$serverUrl/storage';

  static const connectTimeout = Duration(seconds: 30);
  static const requestTimeout = Duration(seconds: 30);

  static const String accountVerificationDocument =
      'account-verification-document';

  // Hospital staff
  static const String hospitalDashboard = '/hospital/dashboard';
  static const String hospitalMyScannedPatients =
      '/hospital/my-scanned-patients';
  static const String hospitalPatients = '/hospital/patients';

  static String hospitalPatientQr(String token) =>
      '/hospital/patient-qr/$token';

  static String hospitalPatientMedicalFiles(String patientId) =>
      '/hospital/patients/$patientId/medical-files';

  static String hospitalPatientMedicalFileDownload(
    String patientId,
    String medicalFileId,
  ) => '/hospital/patients/$patientId/medical-files/$medicalFileId/download';

  static const String hospitalEmergencies = '/hospital/emergencies';

  static String hospitalEmergencyDetails(String id) =>
      '/hospital/emergencies/$id';

  static String hospitalEmergencyNotes(String id) =>
      '/hospital/emergencies/$id/notes';
  static String hospitalAddEmergencyNote(String id) =>
      '/hospital/emergencies/$id/notes';
  static String hospitalResolveEmergency(String id) =>
      '/hospital/emergencies/$id/resolve';

  static String hospitalCheckInEmergency(String id) =>
      '/emergency/$id/check-in';

  static String hospitalPatientMedicalFileDelete(
    String patientId,
    String medicalFileId,
  ) =>
      '/hospital/patients/${Uri.encodeComponent(patientId)}/medical-files/${Uri.encodeComponent(medicalFileId)}';
  static const String hospitalMedications = '/hospital/medications';

  static String hospitalPatientMedications(String patientId) {
    return '/hospital/patients/${Uri.encodeComponent(patientId)}/medications';
  }

  static String hospitalPatientMedicationDelete(
    String patientId,
    String patientMedicationId,
  ) {
    return '/hospital/patients/${Uri.encodeComponent(patientId)}/medications/'
        '${Uri.encodeComponent(patientMedicationId)}';
  }

  static String hospitalPatientMedicalRecord(String patientId) =>
      '/hospital/patients/$patientId/medical-record';
  static String hospitalPatientScanHistory(String patientId) =>
      '/hospital/patients/$patientId/scan-history';

  static String hospitalPatientNotes(String patientId) =>
      '/hospital/patients/$patientId/notes';

  static String hospitalPatientNoteDelete(String patientId, String noteId) =>
      '/hospital/patients/$patientId/notes/$noteId';
  // Auth
  static const String login = '/auth/login';
  static const String registerPatient = '/auth/register/patient';
  static const String registerGuardian = '/auth/register/guardian';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Patient
  static const String patientProfile = '/patient/profile';
  static const String healthCard = '/patient/health-card';
  static const String medicalRecord = '/patient/medical-record';
  static const String medicalHistory = '/patient/medical-history';
  static const String medications = '/patient/medications';
  static const String allergies = '/patient/allergies';
  static const String vaccinations = '/patient/vaccinations';
  static const String vitalSigns = '/patient/vital-signs';
  static const String completePatientProfile = '/patient/profile/complete';
  static const String patientMedicalFiles = '/patient/medical-files';
  static const String patientEmergencies = '/patient/emergencies';
  static const String patientMedications = '/patient/medications';
  // Guardian
  static const String guardianPatients = '/guardian/patients';
  static const String linkPatient = '/guardian/link-patient';
  static const String unlinkPatient = '/guardian/unlink-patient';
  static String guardianPatientMedicalFiles(String patientId) =>
      '/guardian/patient/$patientId/medical-files';
  static const updateGuardianProfile = '/auth/profile';
  static const updatePassword = '/auth/password';
  static String guardianPatientQrToken(String patientId) =>
      '/guardian/patient/$patientId/qr-token';
  // Emergency
  static const String emergencyGuardians = '/emergency/guardians';
  static const String sosTrigger = '/emergency/sos';
  static const String emergencyCurrent = '/emergency/current';
  static const String emergencyContacts = '/emergency/contacts';
  static const String emergencyHistory = '/emergency/history';

  static String sosCancel(String eventId) => '/emergency/$eventId/cancel';

  static String sosCheckIn(String eventId) => '/emergency/$eventId/check-in';

  static String guardianPatientEmergencies(String patientId) =>
      '/guardian/patient/$patientId/emergencies';

  static String guardianPatientEmergencyRead(String patientId, String eventId) {
    return '/guardian/patient/$patientId/emergencies/$eventId/read';
  }

  static String guardianPatientEmergencyDetail(
    String patientId,
    String eventId,
  ) => '/guardian/patient/$patientId/emergencies/$eventId';
  // Hospitals
  static const String nearbyHospitals = '/hospitals/nearby';
  static const String hospitals = '/hospitals';
  static const String hospitalDetails = '/hospitals/';
  static const String hospitalSearch = '/hospitals/search';
  static const String emergencyDepartments = '/hospitals/emergency';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';
  static const String registerFcmToken = '/notifications/fcm-token';

  // Files
  static const String uploadFile = '/files/upload';
  static const String getFiles = '/files';
  static const String deleteFile = '/files/';

  // Settings
  static const String updateProfile = '/settings/profile';
  static const String changePassword = '/settings/change-password';
  static const String deleteAccount = '/settings/delete-account';
}
