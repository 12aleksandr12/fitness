import 'package:dio/dio.dart';
import 'package:fitness_app/core/token_store.dart';
import 'package:flutter/foundation.dart';

String defaultApiBase() {
  if (kIsWeb) {
    return 'http://localhost:3100/api/v2';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:3100/api/v2';
    default:
      return 'http://localhost:3100/api/v2';
  }
}

Dio createDio(TokenStore tokens) {
  final dio = Dio(
    BaseOptions(
      baseUrl: defaultApiBase(),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  var refreshing = false;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await tokens.access();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode != 401 || refreshing) {
          return handler.next(error);
        }
        final refresh = await tokens.refresh();
        if (refresh == null) {
          return handler.next(error);
        }
        refreshing = true;
        try {
          final fresh = await Dio(BaseOptions(baseUrl: dio.options.baseUrl)).post(
            '/auth/refresh',
            data: {'refreshToken': refresh},
          );
          final data = fresh.data as Map<String, dynamic>;
          await tokens.save(
            access: data['accessToken'] as String,
            refresh: data['refreshToken'] as String,
          );
          final req = error.requestOptions;
          req.headers['Authorization'] = 'Bearer ${data['accessToken']}';
          final retry = await dio.fetch(req);
          handler.resolve(retry);
        } catch (_) {
          await tokens.clear();
          handler.next(error);
        } finally {
          refreshing = false;
        }
      },
    ),
  );
  return dio;
}
