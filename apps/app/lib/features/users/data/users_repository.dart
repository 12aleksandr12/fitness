import 'dart:typed_data';

import 'package:dio/dio.dart';

class UsersRepository {
  UsersRepository(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _dio.get<List<dynamic>>('/users');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> profile(String userId) async {
    final path = userId == 'me' ? '/users/me' : '/users/$userId';
    final res = await _dio.get<Map<String, dynamic>>(path);
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> body) async {
    final path = userId == 'me' ? '/users/me' : '/users/$userId';
    final res = await _dio.patch<Map<String, dynamic>>(path, data: body);
    return res.data ?? {};
  }

  Future<Uint8List?> userPhoto(String userId) async {
    try {
      final path = userId == 'me' ? '/users/me/photo' : '/users/$userId/photo';
      final res = await _dio.get<List<int>>(
        path,
        queryParameters: {'t': DateTime.now().millisecondsSinceEpoch},
        options: Options(responseType: ResponseType.bytes),
      );
      final data = res.data;
      if (data == null) {
        return null;
      }
      return Uint8List.fromList(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> uploadPhoto(String userId, List<int> bytes, String filename) async {
    final path = userId == 'me' ? '/users/me/photo' : '/users/$userId/photo';
    await _dio.post(
      path,
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    );
  }

  Future<void> deletePhoto(String userId) async {
    final path = userId == 'me' ? '/users/me/photo' : '/users/$userId/photo';
    await _dio.delete(path);
  }

  Future<List<Map<String, dynamic>>> myPasses() async {
    final res = await _dio.get<List<dynamic>>('/me/passes');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> myLedger() async {
    final res = await _dio.get<List<dynamic>>('/me/ledger');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> adjust(String userId, int visits, String note) async {
    await _dio.post('/users/$userId/ledger', data: {'visits': visits, 'note': note});
  }
}
