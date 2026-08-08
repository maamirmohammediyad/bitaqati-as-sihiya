import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/entities/user.dart';
import 'package:bitaqati_as_sihiya/features/auth/domain/repositories/auth_repository.dart';
import 'package:bitaqati_as_sihiya/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bitaqati_as_sihiya/core/errors/failure.dart';
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String nationalId,
    required String password,
    required String role,
  }) {
    return _repository.login(
      nationalId: nationalId,
      password: password,
      role: role,
    );
  }
}
