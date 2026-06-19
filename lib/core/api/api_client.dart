import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient(AuthTokenProvider tokenProvider)
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 20),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(AuthInterceptor(tokenProvider));
  }

  final Dio dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await dio.post(path, data: data);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await dio.put(path, data: data);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.delete(path, queryParameters: queryParameters);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  ApiException _mapDioException(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final apiError = data['error'] as Map;
      return ApiException(
        code: apiError['code']?.toString() ?? 'API_ERROR',
        message: apiError['message']?.toString() ?? 'Something went wrong',
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message:
          'Could not reach My Calorie. Check your connection and try again.',
      statusCode: error.response?.statusCode,
    );
  }
}
