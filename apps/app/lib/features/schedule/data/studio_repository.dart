import 'dart:typed_data';

import 'package:dio/dio.dart';

class StudioRepository {
  StudioRepository(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> sessions({required DateTime from, required DateTime to}) async {
    final res = await _dio.get<List<dynamic>>(
      '/sessions',
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    );
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> classTypes() async {
    final res = await _dio.get<List<dynamic>>('/class-types');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> createSession(Map<String, dynamic> body) async {
    await _dio.post('/sessions', data: body);
  }

  Future<void> updateSession(String id, Map<String, dynamic> body) async {
    await _dio.patch('/sessions/$id', data: body);
  }

  Future<void> deleteSession(String id) async {
    await _dio.delete('/sessions/$id');
  }

  Future<void> book(String sessionId, {String? userId}) async {
    await _dio.post('/sessions/$sessionId/book', data: {if (userId != null) 'userId': userId});
  }

  Future<void> cancel(String bookingId) async {
    // Fastify rejects application/json with an empty body.
    await _dio.post('/bookings/$bookingId/cancel', data: <String, dynamic>{});
  }

  Future<void> checkIn(String bookingId) async {
    await _dio.post('/bookings/$bookingId/check-in', data: <String, dynamic>{});
  }

  Future<List<Map<String, dynamic>>> sessionLog(String sessionId) async {
    final res = await _dio.get<List<dynamic>>('/sessions/$sessionId/log');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> myBookings() async {
    final res = await _dio.get<List<dynamic>>('/me/bookings');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> myPasses() async {
    final res = await _dio.get<List<dynamic>>('/me/passes');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> myLedger() async {
    final res = await _dio.get<List<dynamic>>('/me/ledger');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> users() async {
    final res = await _dio.get<List<dynamic>>('/users');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> profile(String userId) async {
    final path = userId == 'me' ? '/users/me' : '/users/$userId';
    final res = await _dio.get<Map<String, dynamic>>(path);
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> body) async {
    final res = await _dio.patch<Map<String, dynamic>>('/users/me', data: body);
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

  Future<void> uploadMyPhoto(List<int> bytes, String filename) async {
    await _dio.post(
      '/users/me/photo',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    );
  }

  Future<void> deleteMyPhoto() async {
    await _dio.delete('/users/me/photo');
  }

  Future<List<Map<String, dynamic>>> userPasses(String userId) async {
    final res = await _dio.get<List<dynamic>>('/users/$userId/passes');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> adjust(String userId, int visits, String note) async {
    await _dio.post('/users/$userId/ledger', data: {'visits': visits, 'note': note});
  }

  Future<List<Map<String, dynamic>>> roles() async {
    final res = await _dio.get<List<dynamic>>('/roles');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> permissionCatalog() async {
    final res = await _dio.get<List<dynamic>>('/permissions');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> createRole(String name, List<String> slugs) async {
    await _dio.post('/roles', data: {'name': name, 'permissionSlugs': slugs});
  }

  Future<void> updateRole(String id, List<String> slugs) async {
    await _dio.patch('/roles/$id', data: {'permissionSlugs': slugs});
  }

  Future<void> deleteRole(String id) async {
    await _dio.delete('/roles/$id');
  }

  Future<void> assignRole(String userId, String roleId) async {
    await _dio.post('/users/$userId/role', data: {'roleId': roleId});
  }
}
