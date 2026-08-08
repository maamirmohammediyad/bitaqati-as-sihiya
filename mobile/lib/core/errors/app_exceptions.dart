/// استثناءات التطبيق على مستوى الـ network والـ server.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkConnectionException extends AppException {
  const NetworkConnectionException()
      : super(message: 'No internet connection');
}

class TimeoutException extends AppException {
  const TimeoutException()
      : super(message: 'Connection timed out');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super(message: 'Unauthorized');
}

class NotFoundException extends AppException {
  const NotFoundException()
      : super(message: 'Resource not found');
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    required String message,
    this.errors,
    int? statusCode,
    dynamic data,
  }) : super(
          message: message,
          statusCode: statusCode,
          data: data,
        );
}

class ServerException extends AppException {
  const ServerException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(
          message: message,
          statusCode: statusCode,
          data: data,
        );
}

/// UnknownException بنفس نمط باقي الاستثناءات
class UnknownException extends AppException {
  const UnknownException({
    String message = 'Unknown error occurred',
    int? statusCode,
    dynamic data,
  }) : super(
          message: message,
          statusCode: statusCode,
          data: data,
        );
}