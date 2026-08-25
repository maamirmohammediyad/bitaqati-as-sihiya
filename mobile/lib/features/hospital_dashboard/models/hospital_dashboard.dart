class HospitalDashboard {
  const HospitalDashboard({
    required this.hospital,
    required this.staff,
    required this.statistics,
    required this.recentEmergencies,
  });

  final HospitalInfo hospital;
  final HospitalStaff staff;
  final HospitalStatistics statistics;
  final List<RecentEmergency> recentEmergencies;

  factory HospitalDashboard.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map);

    return HospitalDashboard(
      hospital: HospitalInfo.fromJson(
        Map<String, dynamic>.from(data['hospital'] as Map),
      ),
      staff: HospitalStaff.fromJson(
        Map<String, dynamic>.from(data['staff'] as Map),
      ),
      statistics: HospitalStatistics.fromJson(
        Map<String, dynamic>.from(data['statistics'] as Map),
      ),
      recentEmergencies: (data['recent_emergencies'] as List<dynamic>? ?? [])
          .map(
            (item) => RecentEmergency.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class HospitalInfo {
  const HospitalInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.phone,
    required this.address,
    required this.city,
    required this.isActive,
  });

  final String id;
  final String name;
  final String type;
  final String phone;
  final String? address;
  final String? city;
  final bool isActive;

  factory HospitalInfo.fromJson(Map<String, dynamic> json) {
    return HospitalInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      isActive: json['is_active'] == true,
    );
  }
}

class HospitalStaff {
  const HospitalStaff({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final String role;

  factory HospitalStaff.fromJson(Map<String, dynamic> json) {
    return HospitalStaff(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'مدير المستشفى';
      case 'doctor':
        return 'طبيب';
      case 'nurse':
        return 'ممرض / ممرضة';
      case 'receptionist':
        return 'موظف استقبال';
      default:
        return role;
    }
  }
}

class HospitalStatistics {
  const HospitalStatistics({
    required this.activeEmergencies,
    required this.checkedInToday,
    required this.resolvedToday,
    required this.activeStaffCount,
  });

  final int activeEmergencies;
  final int checkedInToday;
  final int resolvedToday;
  final int activeStaffCount;

  factory HospitalStatistics.fromJson(Map<String, dynamic> json) {
    int value(String key) => (json[key] as num?)?.toInt() ?? 0;

    return HospitalStatistics(
      activeEmergencies: value('active_emergencies'),
      checkedInToday: value('checked_in_today'),
      resolvedToday: value('resolved_today'),
      activeStaffCount: value('active_staff_count'),
    );
  }
}

class RecentEmergency {
  const RecentEmergency({
    required this.id,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.createdAt,
    required this.checkedInAt,
    required this.patient,
  });

  final String id;
  final String status;
  final double latitude;
  final double longitude;
  final String? locationName;
  final DateTime? createdAt;
  final DateTime? checkedInAt;
  final EmergencyPatient patient;

  factory RecentEmergency.fromJson(Map<String, dynamic> json) {
    return RecentEmergency(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      locationName: json['location_name']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      checkedInAt: DateTime.tryParse(json['checked_in_at']?.toString() ?? ''),
      patient: EmergencyPatient.fromJson(
        Map<String, dynamic>.from(json['patient'] as Map? ?? {}),
      ),
    );
  }

  bool get isResolved => status == 'resolved';

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'نشطة';
      case 'checked_in':
        return 'تم الوصول';
      case 'resolved':
        return 'تم إنهاؤها';
      case 'cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }
}

class EmergencyPatient {
  const EmergencyPatient({
    required this.id,
    required this.name,
    required this.phone,
    required this.patientCode,
  });

  final String id;
  final String name;
  final String phone;
  final String patientCode;

  factory EmergencyPatient.fromJson(Map<String, dynamic> json) {
    return EmergencyPatient(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'مريض غير معروف',
      phone: json['phone']?.toString() ?? '',
      patientCode: json['patient_code']?.toString() ?? '',
    );
  }
}