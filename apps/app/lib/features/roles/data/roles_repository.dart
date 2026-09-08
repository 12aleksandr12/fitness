import 'package:dio/dio.dart';

class RolesRepository {
  RolesRepository(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _dio.get<List<dynamic>>('/roles');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> permissionCatalog() async {
    final res = await _dio.get<List<dynamic>>('/permissions');
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> create(String name, List<String> slugs) async {
    await _dio.post('/roles', data: {'name': name, 'permissionSlugs': slugs});
  }

  Future<void> update(String id, List<String> slugs) async {
    await _dio.patch('/roles/$id', data: {'permissionSlugs': slugs});
  }

  Future<void> delete(String id) async {
    await _dio.delete('/roles/$id');
  }
}
