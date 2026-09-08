import 'package:dio/dio.dart';
import 'package:fitness_app/core/token_store.dart';
import 'package:fitness_app/features/auth/data/auth_user.dart';

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  Future<void> login(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    await _saveTokens(res.data!);
  }

  Future<void> register({required String token, required String name, required String password}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'token': token, 'name': name, 'password': password},
    );
    await _saveTokens(res.data!);
  }

  Future<String> invite({required String email, required String roleId}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/invite',
      data: {'email': email, 'roleId': roleId},
    );
    return res.data?['token'] as String? ?? '';
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await _tokens.save(
      access: data['accessToken'] as String,
      refresh: data['refreshToken'] as String,
    );
  }

  Future<AuthUser> me() async {
    final res = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(res.data!);
  }

  Future<void> logout() async {
    final refresh = await _tokens.refresh();
    if (refresh != null) {
      try {
        await _dio.post('/auth/logout', data: {'refreshToken': refresh});
      } catch (_) {}
    }
    await _tokens.clear();
  }
}
