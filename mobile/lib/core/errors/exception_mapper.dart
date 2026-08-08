import 'package:dio/dio.dart';
import 'package:bitaqati_as_sihiya/core/errors/app_exceptions.dart';

AppException mapDioException(DioException e) {
  final error = e.error;

  if (error is AppException) {
    return error;
  }

  // لو ما كان error من نوع AppException، نحاول نُسقِط من response مباشرة
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;

  if (statusCode == null) {
    return const UnknownException();
  }

  final message = data is Map ? data['message']?.toString() : null;

  switch (statusCode) {
    case 401:
      return const UnauthorizedException();
    case 404:
      return const NotFoundException();
    case 422:
      final errors = data is Map
          ? data['errors'] as Map<String, dynamic>?
          : null;
      return ValidationException(
        message: message ?? 'Validation failed',
        errors: errors,
        statusCode: statusCode,
        data: data,
      );
    default:
      return ServerException(
        message: message ?? 'Server error occurred',
        statusCode: statusCode,
        data: data,
      );
  }
}