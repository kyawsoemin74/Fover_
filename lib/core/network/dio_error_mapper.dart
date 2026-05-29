import 'dart:io';

import 'package:dio/dio.dart';

class DioErrorMapper {
  static String map(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Please check your connection.';
    }

    if (error.type == DioExceptionType.unknown && error.error is SocketException) {
      return 'Network unavailable. Please check your internet connection.';
    }

    final responseMessage = _extractResponseMessage(error.response);
    if (responseMessage != null && responseMessage.isNotEmpty) {
      return responseMessage;
    }

    return error.message ?? 'Unknown network error occurred.';
  }

  static String? _extractResponseMessage(Response<dynamic>? response) {
    if (response == null) return null;
    final payload = response.data;
    if (payload is String && payload.isNotEmpty) return payload;
    if (payload is Map<String, dynamic>) {
      return payload['message'] as String? ?? payload['error'] as String?;
    }
    return null;
  }
}
