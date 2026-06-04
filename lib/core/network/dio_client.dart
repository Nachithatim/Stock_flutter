import 'package:dio/dio.dart';

class DioClient {
  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://example.com',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

  final Dio dio;
}
