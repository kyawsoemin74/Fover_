import 'package:dio/dio.dart';
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
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'X-App-Version': AppConfig.appVersion,
    });

    // Future: attach authorization headers and request metadata here.
    handler.next(options);
  }
}

class AppErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Future: implement refresh token handling and centralized error side effects.
    handler.next(err);
  }
}
