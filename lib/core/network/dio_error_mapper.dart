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

    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return 'This information is unavailable right now.';
    }

    if (statusCode == 404) {
      return 'This information is unavailable right now.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'The service is temporarily unavailable. Please try again later.';
    }

    return 'Something went wrong. Please try again later.';
  }
}
