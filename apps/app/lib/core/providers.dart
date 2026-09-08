import 'package:dio/dio.dart';
import 'package:fitness_app/core/api_client.dart';
import 'package:fitness_app/core/token_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final dioProvider = Provider<Dio>((ref) => createDio(ref.watch(tokenStoreProvider)));
