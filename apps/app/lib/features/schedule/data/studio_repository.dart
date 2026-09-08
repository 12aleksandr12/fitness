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

  Future<void> cancel(String bookingId, {String? comment}) async {
    // Fastify rejects application/json with an empty body.
    await _dio.post(
      '/bookings/$bookingId/cancel',
      data: <String, dynamic>{
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
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
}
