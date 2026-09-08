import 'dart:async';

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
  final dio = Dio(BaseOptions(baseUrl: defaultApiBase()));
  Completer<String>? refreshJob;

  Future<String> refreshAccess() async {
    final pending = refreshJob;
    if (pending != null) {
      return pending.future;
    }
    final job = Completer<String>();
    refreshJob = job;
    try {
      final refresh = await tokens.refresh();
      if (refresh == null) {
        throw StateError('No refresh token');
      }
      final fresh = await Dio(BaseOptions(baseUrl: dio.options.baseUrl)).post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final data = fresh.data as Map<String, dynamic>;
      final access = data['accessToken'] as String;
      await tokens.save(access: access, refresh: data['refreshToken'] as String);
      job.complete(access);
      return access;
    } catch (e, st) {
      await tokens.clear();
      if (!job.isCompleted) {
        job.completeError(e, st);
      }
      rethrow;
    } finally {
      refreshJob = null;
    }
  }

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
        final path = error.requestOptions.path;
        if (
          error.response?.statusCode != 401 ||
          path.contains('/auth/refresh') ||
          path.contains('/auth/login') ||
          path.contains('/auth/register')
        ) {
          return handler.next(error);
        }
        try {
          final access = await refreshAccess();
          error.requestOptions.headers['Authorization'] = 'Bearer $access';
          handler.resolve(await dio.fetch(error.requestOptions));
        } catch (_) {
          handler.next(error);
        }
      },
    ),
  );
  return dio;
}
