import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;

  const AuthState._();

  bool get isAuthenticated => this is _Authenticated;
  bool get isLoading => this is _Loading;
  bool get isGuardian =>
      this is _Authenticated && (this as _Authenticated).user.isGuardian;
  bool get isPatient =>
      this is _Authenticated && (this as _Authenticated).user.isPatient;

  User? get user =>
      this is _Authenticated ? (this as _Authenticated).user : null;

String? get errorMessage =>
    this is _Error ? (this as _Error).message : null;
}