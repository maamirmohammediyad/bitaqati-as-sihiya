import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';

class GuardianPatientDashboard {
  final User patient;
  final PatientProfileSummary? profile;
  final EmergencySummary emergency;
  final MedicalFilesSummary medicalFiles;
  final QrSummary? qr;
  final List<EmergencyContactSummary> emergencyContacts;
  final List<HospitalSummary> hospitals;

  const GuardianPatientDashboard({
    required this.patient,
    required this.profile,
    required this.emergency,
    required this.medicalFiles,
    required this.qr,
    required this.emergencyContacts,
    required this.hospitals,
  });

  
  
  factory GuardianPatientDashboard.fromJson(Map<String, dynamic> json) {
    return GuardianPatientDashboard(
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

/// ملخص الملف الطبي (لا نحتاج كل الحقول الحساسة هنا)
class PatientProfileSummary {
  final String? fullName;
  final String? dateOfBirth; // yyyy-MM-dd
  final String? bloodGroup;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final bool isProfileComplete;

  const PatientProfileSummary({
    required this.fullName,
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.isProfileComplete,
  });

  factory PatientProfileSummary.fromJson(Map<String, dynamic> json) {
    return PatientProfileSummary(
      fullName: json['full_name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      bloodGroup: json['blood_group'] as String?,
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      isProfileComplete: (json['is_profile_complete'] as bool?) ?? false,
    );
  }
}

/// ملخص بيانات الطوارئ للمريض
class EmergencySummary {
  final int count;
  final EmergencyEventSummary? lastEvent;

  const EmergencySummary({
    required this.count,
    required this.lastEvent,
  });

  factory EmergencySummary.fromJson(Map<String, dynamic> json) {
    return EmergencySummary(
      count: (json['count'] as num?)?.toInt() ?? 0,
      lastEvent: json['last_event'] != null
          ? EmergencyEventSummary.fromJson(
              json['last_event'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// جزء بسيط من EmergencyEventResource يكفي للوحة التحكم
class EmergencyEventSummary {
  final String id;
  final String status;
  final String? locationName;
  final String? createdAt;
  final String? resolvedAt;

  const EmergencyEventSummary({
    required this.id,
    required this.status,
    required this.locationName,
    required this.createdAt,
    required this.resolvedAt,
  });

  factory EmergencyEventSummary.fromJson(Map<String, dynamic> json) {
    return EmergencyEventSummary(
      id: json['id'] as String,
      status: json['status'] as String,
      locationName: json['location_name'] as String?,
      createdAt: json['created_at'] as String?,
      resolvedAt: json['resolved_at'] as String?,
    );
  }
}

/// ملخص الملفات الطبية (عدد + آخر ملفات)
class MedicalFilesSummary {
  final int count;
  final List<MedicalFileSummary> recent;

  const MedicalFilesSummary({
    required this.count,
    required this.recent,
  });

  factory MedicalFilesSummary.fromJson(Map<String, dynamic> json) {
    return MedicalFilesSummary(
      count: (json['count'] as num?)?.toInt() ?? 0,
      recent: (json['recent'] as List<dynamic>? ?? [])
          .map(
            (e) => MedicalFileSummary.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

/// يمكنك أيضاً استخدام الكلاس الموجود لديك في medical_file.dart لو أردت
class MedicalFileSummary {
  final String id;
  final String originalName;
  final String? fileType;
  final String? description;
  final int? sizeBytes;
  final String? mimeType;
  final String? url;
  final String? createdAt;

  const MedicalFileSummary({
    required this.id,
    required this.originalName,
    required this.fileType,
    required this.description,
    required this.sizeBytes,
    required this.mimeType,
    required this.url,
    required this.createdAt,
  });

  factory MedicalFileSummary.fromJson(Map<String, dynamic> json) {
    return MedicalFileSummary(
      id: json['id'] as String,
      originalName: json['original_name'] as String? ?? '',
      fileType: json['file_type'] as String?,
      description: json['description'] as String?,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
      url: json['url'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

/// ملخص الكود الصحي للمريض
class QrSummary {
  final String token;
  final String? expiresAt;
  final bool isValid;

  const QrSummary({
    required this.token,
    required this.expiresAt,
    required this.isValid,
  });

  factory QrSummary.fromJson(Map<String, dynamic> json) {
    return QrSummary(
      token: json['token'] as String,
      expiresAt: json['expires_at'] as String?,
      isValid: (json['is_valid'] as bool?) ?? false,
    );
  }
}

/// جهة اتصال طوارئ
class EmergencyContactSummary {
  final String id;
  final String fullName;
  final String phone;
  final String? relationship;
  final bool isNotifiable;

  const EmergencyContactSummary({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.relationship,
    required this.isNotifiable,
  });

  factory EmergencyContactSummary.fromJson(Map<String, dynamic> json) {
    return EmergencyContactSummary(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      relationship: json['relationship'] as String?,
      isNotifiable: (json['is_notifiable'] as bool?) ?? false,
    );
  }
}

/// مستشفى / مزود خدمة صحي
class HospitalSummary {
  final String id;
  final String name;
  final String? city;
  final String? state;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? phone;

  const HospitalSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.phone,
  });

  factory HospitalSummary.fromJson(Map<String, dynamic> json) {
    return HospitalSummary(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
    );
  }
}