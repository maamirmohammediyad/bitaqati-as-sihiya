import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const LoginRequest._();

  const factory LoginRequest({
    required String identifier,
    required String password,
    required String role,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toRequestJson() {
    return {
      'role': role,
      'password': password,
      if (role == 'health_worker') 'employee_code': identifier,
      if (role == 'patient' || role == 'guardian')
        'national_id': identifier,
      if (role == 'super_admin') 'email': identifier,
    };
  }
}