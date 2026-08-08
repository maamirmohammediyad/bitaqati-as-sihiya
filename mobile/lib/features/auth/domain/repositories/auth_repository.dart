import 'package:dartz/dartz.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:bitaqati_as_sihiya/core/errors/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String nationalId,
    required String password,
    required String role,
  });

  Future<Either<Failure, User>> registerPatient({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  });

  Future<Either<Failure, User>> registerGuardian({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    String? patientCode,
    String? relationship,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();
}