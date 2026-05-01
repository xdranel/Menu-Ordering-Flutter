import 'package:dio/dio.dart';
import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/core/exceptions.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = _build();

  static Dio get instance => _dio;

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Logs requests + responses in debug builds.
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        final typed = _mapError(e);
        handler.reject(DioException(
          requestOptions: e.requestOptions,
          error: typed,
          message: typed.toString(),
        ));
      },
    ));

    return dio;
  }

  static Exception _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        final msg = (data is Map ? data['message'] : null) ?? e.message ?? 'Unknown error';
        return ApiException(statusCode: code, message: msg.toString());
      default:
        return NetworkException(message: e.message ?? 'Unexpected error');
    }
  }
}
