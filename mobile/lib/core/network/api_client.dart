import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitaqati_as_sihiya/core/constants/api_constants.dart';
import 'package:bitaqati_as_sihiya/core/storage/secure_storage.dart';
import 'package:bitaqati_as_sihiya/core/errors/app_exceptions.dart';
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage);
});

class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.requestTimeout,
        sendTimeout: ApiConstants.requestTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
  _AuthInterceptor(_secureStorage),
  _ErrorInterceptor(), // فعِّله هنا
  LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (object) {
      print(object); // مؤقتًا اطبع اللوج في الـ console
    },
  ),
]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.deleteToken();
    }
    handler.next(err);
  }
}
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final statusCode = err.response?.statusCode;
    final rawData = err.response?.data;

    print('API ERROR TYPE: ${err.type}');
    print('API ERROR STATUS: $statusCode');
    print('API ERROR DATA: $rawData');

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const TimeoutException(),
          ),
        );
        break;

      case DioExceptionType.connectionError:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkConnectionException(),
          ),
        );
        break;

      case DioExceptionType.badResponse:
        // نتعامل مع رد HTTP (statusCode + body)
        Map<String, dynamic>? mapData;
        String? message;

        if (rawData is Map<String, dynamic>) {
          mapData = rawData;
          message = mapData['message']?.toString();
        } else if (rawData is String) {
          // لو الرد نصي فقط (مثلاً HTML أو رسالة plain)
          message = rawData;
        }

        switch (statusCode) {
          case 401:
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: const UnauthorizedException(),
              ),
            );
            break;

          case 404:
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: const NotFoundException(),
              ),
            );
            break;

          case 422:
            final errors = mapData?['errors'] as Map<String, dynamic>?;
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: ValidationException(
                  message: message ?? 'Validation failed',
                  errors: errors,
                  statusCode: statusCode,
                  data: rawData,
                ),
              ),
            );
            break;

          default:
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: ServerException(
                  message: message ?? 'Server error occurred',
                  statusCode: statusCode,
                  data: rawData,
                ),
              ),
            );
        }
        break;

      case DioExceptionType.cancel:
        handler.next(err);
        break;

      default:
        // هنا أخطاء مثل FormatException, SocketException, إلخ
        print('DIO UNKNOWN ERROR: type=${err.type}, error=${err.error}');
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: UnknownException(
              message: err.error?.toString() ?? 'Unknown error occurred',
              statusCode: statusCode,
              data: rawData,
            ),
          ),
        );
    }
  }
}