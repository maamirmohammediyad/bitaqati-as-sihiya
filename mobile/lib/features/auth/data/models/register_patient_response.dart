import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';

part 'register_patient_response.freezed.dart';

User _userFromJson(Map<String, dynamic> json) => User.fromJson(json);
Map<String, dynamic> _userToJson(User user) => user.toJson();

@freezed
class RegisterPatientResponse with _$RegisterPatientResponse {
  const factory RegisterPatientResponse({
    @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
    required User user,
    @JsonKey(name: 'token') required String token,
  }) = _RegisterPatientResponse;

  /// JSON من Laravel:
  /// {
  ///   "data": {
  ///     "user": {...},
  ///     "token": "..."
  ///   }
  /// }
  factory RegisterPatientResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return RegisterPatientResponse(
      user: _userFromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }
}