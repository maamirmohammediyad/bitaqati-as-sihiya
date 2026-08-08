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

  // جديد: قائمة المرضى المرتبطين بهذا المستخدم (تُستخدم عندما يكون Guardian)
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
    this.patients = const [], // قيمة افتراضية فارغة
  });

  String get fullName => '$firstName $lastName';

  bool get isPatient => role == 'patient';
  bool get isGuardian => role == 'guardian';

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
    List<User>? patients,
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
      patients: patients ?? this.patients,
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
      // لا نرسل patients حالياً
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // لو جاءنا الرد كامل من API (فيه data.user)
      final root = json['data'] != null && json['data'] is Map<String, dynamic>
          ? (json['data']['user'] ?? json['data']) as Map<String, dynamic>
          : json;

      final nationalId =
          root['national_id'] as String? ??
          root['nationalId'] as String? ??
          '';

      final name = root['name'] as String?;
      final firstName = root['first_name'] as String?;
      final lastName = root['last_name'] as String?;

      final profile = root['profile'] as Map<String, dynamic>?;

      final profileFullName = profile?['full_name'] as String?;
      final profileFirstName = profileFullName?.split(' ').first;
      final profileLastName =
          profileFullName?.split(' ').skip(1).join(' ').trim();

      final resolvedFirstName =
          firstName ??
          profileFirstName ??
          (name != null ? name.split(' ').first : '');
      final resolvedLastName =
          lastName ??
          profileLastName ??
          (name != null ? name.split(' ').skip(1).join(' ') : '');

      final rawId = root['id'];
      final id = rawId?.toString() ?? '';

      final patientCode = root['patient_code'] as String?;

      final isProfileComplete =
          profile?['is_profile_complete'] as bool? ??
          root['is_profile_completed'] as bool? ??
          false;
      final dateOfBirthStr = profile?['date_of_birth'] as String?;
      // جديد: قراءة قائمة المرضى (لو موجودة) – هنا نفترض أن JSON المريض الواحد
      // هو مباشرة نفس الشكل (بدون data.user)، كما في مثال الـ guardian الذي أرسلته.
      final patientsJson = root['patients'] as List<dynamic>?;
      final patients = patientsJson != null
          ? patientsJson
              .whereType<Map<String, dynamic>>()
              .map((p) => User.fromJson(p)) // p لا يحتوي data، فيُعامل كـ root مباشرة
              .toList()
          : <User>[];

      return User(
        id: id,
        nationalId: nationalId,
        firstName: resolvedFirstName,
        lastName: resolvedLastName,
        role: root['role'] as String? ?? 'patient',
        email: root['email'] as String?,
        phone: root['phone'] as String?,
        bloodType: profile?['blood_group'] as String?,
        dateOfBirth: dateOfBirthStr != null ? DateTime.parse(dateOfBirthStr) : null,
        isActive: root['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(root['created_at'] as String),
        patientCode: patientCode,
        isProfileComplete: isProfileComplete,
        patients: patients,
      );
    } catch (e) {
      throw e;
    }
  }
}