import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitaqati_as_sihiya/core/network/api_client.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/repositories/auth_repository.dart';
import 'package:bitaqati_as_sihiya/features/auth/presentation/providers/auth_state.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial());

  Future<void> login({
    required String nationalId,
    required String password,
    required String role,
  }) async {
    state = const AuthState.loading();

    final result = await _repository.login(
      nationalId: nationalId,
      password: password,
      role: role,
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// تسجيل دخول موظف الصحة.
  ///
  /// ملاحظة: سنُمرر employeeCode مؤقتًا إلى nationalId، لأن واجهة
  /// AuthRepository الحالية تستخدم اسم nationalId. سنعدل طبقة الـRepository
  /// لاحقًا لتقبل employeeCode باسم واضح.
  Future<void> loginHealthWorker({
    required String employeeCode,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _repository.login(
      nationalId: employeeCode,
      password: password,
      role: 'health_worker',
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> registerPatient({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _repository.registerPatient(
      nationalId: nationalId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      password: password,
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> registerGuardian({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    String? patientCode,
    String? relationship,
  }) async {
    state = const AuthState.loading();

    final result = await _repository.registerGuardian(
      nationalId: nationalId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      password: password,
      patientCode: patientCode,
      relationship: relationship,
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();

    final result = await _repository.logout();

    result.fold(
      (_) => state = const AuthState.unauthenticated(),
      (_) => state = const AuthState.unauthenticated(),
    );
  }

  Future<void> checkAuth() async {
    final result = await _repository.getCurrentUser();

    result.fold(
      (_) => state = const AuthState.unauthenticated(),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> refreshCurrentUser() async {
    final result = await _repository.getCurrentUser();

    result.fold(
      (_) => state = const AuthState.unauthenticated(),
      (user) => state = AuthState.authenticated(user),
    );
  }

  void updateUser(User user) {
    state = AuthState.authenticated(user);
  }

  Future<String?> updateGuardianProfile({
    required String name,
    required String phone,
    String? email,
  }) async {
    final previousState = state;

    final result = await _repository.updateGuardianProfile(
      name: name,
      phone: phone,
      email: email,
    );

    return result.fold(
      (failure) {
        state = previousState;
        return failure.message;
      },
      (user) {
        state = AuthState.authenticated(user);
        return null;
      },
    );
  }

  Future<String?> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _repository.updatePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    return result.fold(
      (failure) => failure.message,
      (_) {
        state = const AuthState.unauthenticated();
        return null;
      },
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> registerDeviceToken(ApiClient apiClient) async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    await apiClient.post(
      '/notifications/register-device',
      data: {
        'fcm_token': token,
      },
    );
  }
}