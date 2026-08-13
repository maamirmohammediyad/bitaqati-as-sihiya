import 'package:dio/dio.dart';

class AccountRemoteDataSource {
  final Dio dio;

  AccountRemoteDataSource(this.dio);

  Future<void> updateEmail({
  required String email,
}) async {
  await dio.put(
    '/patient/email',
    data: {
      'email': email.trim(),
    },
  );
}

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await dio.put(
      '/auth/password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}
