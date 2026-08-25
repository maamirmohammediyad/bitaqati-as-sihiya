import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:bitaqati_as_sihiya/core/errors/failure.dart';
import 'package:bitaqati_as_sihiya/core/errors/exception_mapper.dart';
import 'package:bitaqati_as_sihiya/core/errors/app_exceptions.dart';
import 'package:bitaqati_as_sihiya/core/storage/secure_storage.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/models/login_request.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/models/login_response.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/models/register_patient_response.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/repositories/auth_repository.dart';
import 'dart:convert';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  // ---------------- login ----------------

  @override
  Future<Either<Failure, User>> login({
    required String nationalId,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequest(
  identifier: nationalId,
  password: password,
  role: role,
),
      );
      await _saveAuthData(response);
      return Right(response.user);
    } on DioException catch (e) {
      final appException = mapDioException(e);

      if (appException is ValidationException) {
        return Left(Failure(
          message: appException.message,
          error: appException,
        ));
      }

      if (appException is ServerException) {
        return Left(Failure(
          message: appException.message,
          error: appException,
        ));
      }

      if (appException is NetworkConnectionException) {
        return const Left(
          Failure(message: 'No internet connection'),
        );
      }

      return Left(Failure(
        message: appException.message,
        error: appException,
      ));
    } catch (e) {
      return Left(Failure(message: e.toString(), error: e));
    }
  }

  // ---------------- registerPatient ----------------

  @override
  Future<Either<Failure, User>> registerPatient({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    try {
      final RegisterPatientResponse response =
          await _remoteDataSource.registerPatient(
        nationalId: nationalId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
      );

      await Future.wait([
  _secureStorage.saveToken(response.token),
  _secureStorage.saveUserId(response.user.id),
  _secureStorage.saveUserRole(response.user.role),
  _secureStorage.saveLoginTimestamp(DateTime.now()),
  _secureStorage.saveUserJson(jsonEncode(response.user.toJson())),
]);

      return Right(response.user);
    } on DioException catch (e) {
      final appException = mapDioException(e);

      if (appException is ValidationException) {
        return Left(Failure(
          message: appException.message,
          error: appException,
        ));
      }

      if (appException is ServerException) {
        return Left(Failure(
          message: appException.message,
          error: appException,
        ));
      }

      if (appException is NetworkConnectionException) {
        return const Left(
          Failure(message: 'No internet connection'),
        );
      }

      return Left(Failure(
        message: appException.message,
        error: appException,
      ));
    } catch (e, st) {
  debugPrint('RegisterPatient error: $e');
  debugPrint('Stack: $st');
  return Left(Failure(message: e.toString(), error: e));
}
  }

  // ---------------- registerGuardian ----------------

  @override
  Future<Either<Failure, User>> registerGuardian({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    String? patientCode,
    String? relationship,
  }) async {
    try {
      final response = await _remoteDataSource.registerGuardian(
        nationalId: nationalId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
        patientCode: patientCode,
        relationship: relationship,
      );
      await _saveAuthData(response);
      return Right(response.user);
    } on DioException catch (e) {
      final appException = mapDioException(e);

      if (appException is ValidationException) {
        return Left(Failure(
          message: appException.message,
          error: appException,
        ));
      }

      if (appException is ServerException) {
        return Left(Failure(
          message: appException.message,
          error: appException,
        ));
      }

      if (appException is NetworkConnectionException) {
        return const Left(
          Failure(message: 'No internet connection'),
        );
      }

      return Left(Failure(
        message: appException.message,
        error: appException,
      ));
    } catch (e, st) {
      // أضف هذا السطرين
      debugPrint('RegisterGuardian unknown error: $e');
      debugPrint('Stack: $st');

      return Left(Failure(message: e.toString(), error: e));
    }
  }

  // ---------------- logout ----------------

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _clearAuthData();
      return const Right(null);
    } on DioException catch (e) {
      await _clearAuthData();

      final appException = mapDioException(e);

      if (appException is ServerException) {
        return Left(Failure(
          message: appException.message,
          error: appException,
        ));
      }

      if (appException is NetworkConnectionException) {
        return const Left(
          Failure(message: 'No internet connection'),
        );
      }

      return Left(Failure(
        message: appException.message,
        error: appException,
      ));
    } catch (e) {
      await _clearAuthData();
      return Left(Failure(message: e.toString(), error: e));
    }
  }

  // ---------------- getCurrentUser ----------------
@override
Future<Either<Failure, User>> getCurrentUser() async {
  try {
    final userJson = await _secureStorage.getUserJson();
    final loginAt = await _secureStorage.getLoginTimestamp();

    if (userJson == null || loginAt == null) {
      return const Left(
        Failure(message: 'No authenticated user'),
      );
    }

    if (DateTime.now().difference(loginAt).inHours >= 24) {
      await _clearAuthData();

      return const Left(
        Failure(message: 'Session expired'),
      );
    }

    final decoded = jsonDecode(userJson) as Map<String, dynamic>;
    return Right(User.fromJson(decoded));
  } catch (e) {
    await _clearAuthData();
    return Left(Failure(message: e.toString(), error: e));
  }
}
  // ---------------- helpers ----------------

  Future<void> _saveAuthData(LoginResponse response) async {
  final now = DateTime.now();
  final userJson = jsonEncode(response.user.toJson());

  await Future.wait([
    _secureStorage.saveToken(response.token),
    _secureStorage.saveUserId(response.user.id),
    _secureStorage.saveUserRole(response.user.role),
    _secureStorage.saveLoginTimestamp(now),
    _secureStorage.saveUserJson(userJson),
  ]);
}

  Future<void> _clearAuthData() async {
    await _secureStorage.clearAll();
  }
  @override
Future<Either<Failure, User>> updateGuardianProfile({
  required String name,
  required String phone,
  String? email,
}) async {
  try {
    final response = await _remoteDataSource.updateGuardianProfile(
      name: name,
      phone: phone,
      email: email,
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = User.fromJson(data);

    await _secureStorage.saveUserJson(jsonEncode(user.toJson()));

    return Right(user);
  } on DioException catch (e) {
    final exception = mapDioException(e);
    return Left(Failure(
      message: exception.message,
      error: exception,
    ));
  } catch (e) {
    return Left(Failure(message: e.toString(), error: e));
  }
}
@override
Future<Either<Failure, void>> updatePassword({
  required String currentPassword,
  required String password,
  required String passwordConfirmation,
}) async {
  try {
    await _remoteDataSource.updatePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    await _clearAuthData();

    return const Right(null);
  } on DioException catch (e) {
    final exception = mapDioException(e);
    return Left(Failure(
      message: exception.message,
      error: exception,
    ));
  } catch (e) {
    return Left(Failure(message: e.toString(), error: e));
  }
}
}