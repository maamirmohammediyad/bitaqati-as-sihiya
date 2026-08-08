class ApiConstants {
  ApiConstants._();

  /// Emulator: 10.0.2.2 يشير إلى localhost على جهاز التطوير.
  /// Production example: https://api.example.com
  static const serverUrl = 'http://10.0.2.2:8000';

  /// رابط Laravel API.
  static const baseUrl = '$serverUrl/api';

  /// الملفات العامة القادمة من Laravel storage.
  static const storageUrl = '$serverUrl/storage';

  static const connectTimeout = Duration(seconds: 10);
  static const requestTimeout = Duration(seconds: 10);

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
  // Guardian
  static const String guardianPatients = '/guardian/patients';
  static const String linkPatient = '/guardian/link-patient';
  static const String unlinkPatient = '/guardian/unlink-patient';
  static String guardianPatientMedicalFiles(String patientId) =>'/guardian/patient/$patientId/medical-files';
  // Emergency
  static const String emergencyGuardians = '/emergency/guardians';
  static const String sosTrigger = '/emergency/sos';
  static const String sosCancel = '/emergency/sos/cancel';
  static const String emergencyContacts = '/emergency/contacts';
  static const String emergencyHistory = '/emergency/history';
  static String guardianPatientEmergencies(String patientId) => '/guardian/patient/$patientId/emergencies';
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
