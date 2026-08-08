import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.statusCode = 401,
    super.data,
  });
}

class NotFoundException extends ServerException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.statusCode = 404,
    super.data,
  });
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkConnectionException extends ServerException {
  const NetworkConnectionException({
    super.message = 'No internet connection',
    super.statusCode = 0,
  });
}

class TimeoutException extends ServerException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.statusCode = 408,
  });
}

class UnknownException extends ServerException {
  const UnknownException({
    super.message = 'An unknown error occurred',
    super.statusCode,
  });
}

/// تحويل DioException إلى Exception خاص بنا
Exception mapDioException(DioException error) {
  final response = error.response;

  // مشاكل الاتصال
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.unknown) {
    return const NetworkConnectionException();
  }

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return const TimeoutException();
  }

  if (response != null) {
    final statusCode = response.statusCode;
    final data = response.data;

    // 422 Validation من Laravel
    if (statusCode == 422) {
      String message = 'Validation error';
      Map<String, dynamic>? errors;

      developer.log(
        '422 RESPONSE DATA: $data',
        name: 'api_exceptions',
      );

      if (data is Map<String, dynamic>) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) {
          message = msg;
        }

        final err = data['errors'];
        if (err is Map<String, dynamic>) {
          errors = err;

          if (err.isNotEmpty) {
            final firstKey = err.keys.first;
            final firstErrorList = err[firstKey];
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              final firstMessage = firstErrorList.first;
              if (firstMessage is String && firstMessage.isNotEmpty) {
                message = firstMessage;
              }
            }
          }
        }
      }

      return ValidationException(message: message, errors: errors);
    }

    // 401
    if (statusCode == 401) {
      return UnauthorizedException(
        message: _extractMessage(data) ?? 'Unauthorized access',
        statusCode: statusCode,
      );
    }

    // 404
    if (statusCode == 404) {
      return NotFoundException(
        message: _extractMessage(data) ?? 'Resource not found',
        statusCode: statusCode,
      );
    }

    // باقي أكواد السيرفر
    return ServerException(
      message: _extractMessage(data) ?? 'Server error',
      statusCode: statusCode,
      data: data,
    );
  }

  return const UnknownException();
}

String? _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    final msg = data['message'];
    if (msg is String && msg.isNotEmpty) return msg;
  }
  return null;
}