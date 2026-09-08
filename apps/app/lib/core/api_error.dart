import 'package:dio/dio.dart';

String? apiErrorCode(Object error) {
  if (error is! DioException) {
    return null;
  }
  final data = error.response?.data;
  if (data is Map && data['code'] is String) {
    return data['code'] as String;
  }
  return null;
}
