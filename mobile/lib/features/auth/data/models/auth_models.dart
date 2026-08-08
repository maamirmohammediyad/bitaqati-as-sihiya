class AuthResponse {
  final UserDto user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return AuthResponse(
      user: UserDto.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
      token: data['token']?.toString() ?? '',
    );
  }
}

class UserDto {
  final String id;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? patientCode;
  final PatientProfileDto? patientProfile;

  UserDto({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.patientCode,
    this.patientProfile,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'patient',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      patientCode: json['patient_code'] as String?,
      patientProfile: json['patient_profile'] != null
          ? PatientProfileDto.fromJson(
              json['patient_profile'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class PatientProfileDto {
  final String id;
  final String? firstName;
  final String? lastName;
  final bool isProfileComplete;

  PatientProfileDto({
    required this.id,
    this.firstName,
    this.lastName,
    required this.isProfileComplete,
  });

  factory PatientProfileDto.fromJson(Map<String, dynamic> json) {
    return PatientProfileDto(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
    );
  }
}