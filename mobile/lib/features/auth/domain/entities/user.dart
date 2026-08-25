class HospitalStaffHospital {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;
  final String status;
  final String? staffRole;
  final bool staffIsActive;
  final DateTime? joinedAt;

  const HospitalStaffHospital({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    required this.isActive,
    required this.status,
    this.staffRole,
    required this.staffIsActive,
    this.joinedAt,
  });

  bool get isApprovedAndActive => isActive && status == 'approved';

  bool get isDoctor => staffRole == 'doctor';

  bool get isAdmin => staffRole == 'admin';

  bool get isReceptionist => staffRole == 'receptionist';

  bool get isNurse => staffRole == 'nurse';

  factory HospitalStaffHospital.fromJson(Map<String, dynamic> json) {
    return HospitalStaffHospital(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['is_active'] == true,
      status: json['status']?.toString() ?? '',
      staffRole: json['staff_role']?.toString(),
      staffIsActive: json['staff_is_active'] == true,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.tryParse(json['joined_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'is_active': isActive,
      'status': status,
      'staff_role': staffRole,
      'staff_is_active': staffIsActive,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }
}

class User {
  final String id;
  final String nationalId;
  final String firstName;
  final String lastName;
  final String role;
  final String? email;
  final String? phone;
  final String? bloodType;
  final DateTime? dateOfBirth;
  final bool isActive;
  final DateTime createdAt;
  final String? patientCode;
  final bool isProfileComplete;
  final String verificationStatus;
// unsubmitted | pending | approved | rejected
  /// خاص بموظف الصحة.
  final String? employeeCode;

  /// قائمة المؤسسات الصحية المرتبطة بموظف الصحة.
  final List<HospitalStaffHospital> hospitals;

  /// قائمة المرضى المرتبطين بالمستخدم عندما يكون وليًا.
  final List<User> patients;

  const User({
    required this.id,
    required this.nationalId,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.email,
    this.phone,
    this.bloodType,
    this.dateOfBirth,
    this.isActive = true,
    required this.createdAt,
    this.patientCode,
    this.isProfileComplete = false,
    this.employeeCode,
    this.hospitals = const [],
    this.patients = const [],
    this.verificationStatus = 'unsubmitted',
  });

  String get fullName =>
      '$firstName $lastName'.trim().replaceAll(RegExp(r'\s+'), ' ');

  bool get isPatient => role == 'patient';

  bool get isGuardian => role == 'guardian';

  bool get isHealthWorker => role == 'health_worker';

  bool get isSuperAdmin => role == 'super_admin';

  /// أول مستشفى معتمد ونشط، والموظف نشط ضمنه.
  HospitalStaffHospital? get activeHospital {
    for (final hospital in hospitals) {
      if (hospital.isApprovedAndActive && hospital.staffIsActive) {
        return hospital;
      }
    }

    return null;
  }

  String? get hospitalStaffRole => activeHospital?.staffRole;

  bool get isHospitalAdmin => hospitalStaffRole == 'admin';

  bool get isHospitalReceptionist => hospitalStaffRole == 'receptionist';

  bool get isHospitalDoctor => hospitalStaffRole == 'doctor';

  bool get isHospitalNurse => hospitalStaffRole == 'nurse';

  bool get isHospitalStaff => hospitalStaffRole == 'staff';

  /// الطبيب وحده يستطيع إضافة وحذف الملفات الطبية.
  bool get canManageHospitalMedicalFiles => isHospitalDoctor;

  /// الاستقبال أو مدير المستشفى يستطيعان تسجيل وصول حالة طارئة.
  bool get canCheckInHospitalEmergency =>
      isHospitalAdmin || isHospitalReceptionist;

  /// المدير والطبيب والممرض يستطيعون إنهاء الحالة الطارئة.
  bool get canResolveHospitalEmergency =>
      isHospitalAdmin || isHospitalDoctor || isHospitalNurse;

  /// كل موظف مستشفى نشط يستطيع مسح QR وعرض المعلومات المتاحة.
  bool get canScanPatientQr =>
      isHealthWorker && activeHospital != null;

  User copyWith({
    String? id,
    String? nationalId,
    String? firstName,
    String? lastName,
    String? role,
    String? email,
    String? phone,
    String? bloodType,
    DateTime? dateOfBirth,
    bool? isActive,
    DateTime? createdAt,
    String? patientCode,
    bool? isProfileComplete,
    String? employeeCode,
    List<HospitalStaffHospital>? hospitals,
    List<User>? patients,
    String? verificationStatus,
  }) {
    return User(
      id: id ?? this.id,
      nationalId: nationalId ?? this.nationalId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      patientCode: patientCode ?? this.patientCode,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      employeeCode: employeeCode ?? this.employeeCode,
      hospitals: hospitals ?? this.hospitals,
      patients: patients ?? this.patients,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'national_id': nationalId,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'email': email,
      'phone': phone,
      'blood_type': bloodType,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'patient_code': patientCode,
      'is_profile_complete': isProfileComplete,
      'employee_code': employeeCode,
      'verification_status': verificationStatus,
      'hospitals': hospitals.map((hospital) => hospital.toJson()).toList(),

    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    final Map<String, dynamic> root;

    if (rawData is Map<String, dynamic>) {
      final dynamic rawUser = rawData['user'];
      root = rawUser is Map<String, dynamic> ? rawUser : rawData;
    } else {
      root = json;
    }

    final nationalId =
        root['national_id']?.toString() ??
        root['nationalId']?.toString() ??
        '';

    final name = root['name']?.toString();
    final firstName = root['first_name']?.toString();
    final lastName = root['last_name']?.toString();

    final dynamic rawProfile = root['profile'];
    final profile = rawProfile is Map<String, dynamic> ? rawProfile : null;

    final profileFullName = profile?['full_name']?.toString();
    final profileNameParts = profileFullName
        ?.trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    final nameParts = name
        ?.trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    final resolvedFirstName =
        firstName ??
        (profileNameParts?.isNotEmpty == true ? profileNameParts!.first : null) ??
        (nameParts?.isNotEmpty == true ? nameParts!.first : '');

    final resolvedLastName =
        lastName ??
        (profileNameParts != null && profileNameParts.length > 1
            ? profileNameParts.skip(1).join(' ')
            : null) ??
        (nameParts != null && nameParts.length > 1
            ? nameParts.skip(1).join(' ')
            : '');

    final rawPatients = root['patients'];
    final patients = rawPatients is List
        ? rawPatients
            .whereType<Map>()
            .map(
              (patient) =>
                  User.fromJson(Map<String, dynamic>.from(patient)),
            )
            .toList()
        : <User>[];

    final rawHospitals = root['hospitals'];
    final hospitals = rawHospitals is List
        ? rawHospitals
            .whereType<Map>()
            .map(
              (hospital) => HospitalStaffHospital.fromJson(
                Map<String, dynamic>.from(hospital),
              ),
            )
            .toList()
        : <HospitalStaffHospital>[];

    final profileCompleteValue =
        profile?['is_profile_complete'] ??
        root['is_profile_complete'] ??
        root['is_profile_completed'];

    final rawCreatedAt = root['created_at']?.toString();
    final verificationStatus =
    root['verification_status']?.toString() ?? 'unsubmitted';
    return User(
      id: root['id']?.toString() ?? '',
      nationalId: nationalId,
      firstName: resolvedFirstName,
      lastName: resolvedLastName,
      role: root['role']?.toString() ?? 'patient',
      email: root['email']?.toString(),
      phone: root['phone']?.toString(),
      bloodType: profile?['blood_group']?.toString() ??
          root['blood_type']?.toString(),
      dateOfBirth: DateTime.tryParse(
        profile?['date_of_birth']?.toString() ??
            root['date_of_birth']?.toString() ??
            '',
      ),
      isActive: root['is_active'] == true,
      createdAt: DateTime.tryParse(rawCreatedAt ?? '') ?? DateTime.now(),
      patientCode: root['patient_code']?.toString(),
      isProfileComplete: profileCompleteValue == true,
      verificationStatus: verificationStatus,
      employeeCode: root['employee_code']?.toString(),
      hospitals: hospitals,
      patients: patients,
    );
  }

  bool get canViewHospitalEmergencies {
  return isHealthWorker &&
      const <String>[
        'admin',
        'receptionist',
        'doctor',
        'nurse',
      ].contains(hospitalStaffRole);
}

bool get isVerificationApproved =>
    verificationStatus.trim().toLowerCase() == 'approved';
}