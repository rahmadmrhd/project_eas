import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final _dio = Dio(); // With default `Options`.

Dio get dio {
  _dio
    ..options.baseUrl = 'https://7fn1bhg9-3000.asse.devtunnels.ms'
    ..options.connectTimeout = const Duration(seconds: 10)
    ..options.receiveTimeout = const Duration(seconds: 10)
    ..httpClientAdapter;
  if (kDebugMode) {
    _dio.interceptors.add(
      LogInterceptor(
          responseBody: true,
          error: true,
          requestHeader: false,
          responseHeader: false,
          request: true,
          requestBody: true),
    );
  }
  return _dio;
}
