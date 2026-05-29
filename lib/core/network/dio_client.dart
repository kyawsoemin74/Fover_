import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/config/app_config.dart';
import 'package:fover/core/network/interceptor.dart';

final dioProvider = Provider<Dio>((ref) => DioClient.shared.dio);

class DioClient {
  DioClient({Dio? dio}) : dio = dio ?? _sharedDio;

  final Dio dio;

  static final Dio _sharedDio = _createDio();

  static DioClient get shared => DioClient(dio: _sharedDio);

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
    dio.interceptors.addAll(AppInterceptors.build());
    return dio;
  }

  static bool shouldRetry(DioException exception) {
    return exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.connectionError ||
        exception.error is SocketException;
  }
}