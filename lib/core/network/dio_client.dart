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
			sendTimeout: const Duration(seconds: AppConfig.connectTimeout),
			responseType: ResponseType.json,
			headers: {
				'Accept': 'application/json',
				'Content-Type': 'application/json',
			},
		);

		final dio = Dio(options);
		dio.interceptors.add(LogInterceptor(
			requestHeader: false,
			requestBody: false,
			responseHeader: false,
			responseBody: false,
			error: true,
		));
		return dio;
	}
}