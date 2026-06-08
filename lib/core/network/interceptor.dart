import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fover/core/config/app_config.dart';

class AppInterceptors {
  static List<Interceptor> build() {
    return [
      AppRequestInterceptor(),
      AppErrorInterceptor(),
      LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    ];
  }
}

class AppRequestInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'X-App-Version': AppConfig.appVersion,
    });

    _storage.read(key: 'fover_auth_access_token').then((token) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }).catchError((Object error) {
      handler.next(options);
    });
  }
}

class AppErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Future: implement refresh token handling and centralized error side effects.
    handler.next(err);
  }
}
