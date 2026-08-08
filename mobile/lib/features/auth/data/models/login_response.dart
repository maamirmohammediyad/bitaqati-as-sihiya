import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';

part 'login_response.freezed.dart';

User _userFromJson(Map<String, dynamic> json) => User.fromJson(json);
Map<String, dynamic> _userToJson(User user) => user.toJson();

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
    required User user,
    @JsonKey(name: 'token') required String token,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      user: _userFromJson(data['user'] as Map<String, dynamic>),
      token: data['token']?.toString() ?? '',
    );
  }
}