import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fover/core/config/app_config.dart';

class DioClient {
  DioClient({Dio? dio}) : dio = dio ?? _createDio();

  final Dio dio;

  static Dio _createDio() {
    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(seconds: AppConfig.receiveTimeout),
      sendTimeout: const Duration(seconds: AppConfig.sendTimeout),
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'X-App-Version': AppConfig.appVersion,
      },
    );

    final dio = Dio(options);
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        final requestOptions = error.requestOptions;
        final retryCount = requestOptions.extra['retry'] as int? ?? 0;

        if (retryCount < AppConfig.retryAttempts && _shouldRetry(error)) {
          requestOptions.extra['retry'] = retryCount + 1;
          await Future<void>.delayed(const Duration(milliseconds: AppConfig.retryDelayMillis));

          try {
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          } catch (retryError) {
            if (retryError is DioException) {
              return handler.next(retryError);
            }
            return handler.next(DioException(requestOptions: requestOptions, error: retryError));
          }
        }

        return handler.next(error);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
    ));

    return dio;
  }

  static bool _shouldRetry(DioException exception) {
    return exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.connectionError ||
        exception.error is SocketException;
  }
}