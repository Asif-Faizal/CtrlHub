import 'package:get_it/get_it.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/core/storage/token_storage.dart';
import 'package:ctrlhub_mobile/features/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies({String? baseUrl}) async {
  final apiBase = baseUrl ??
      const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8080/api/v1');

  sl.registerLazySingleton(() => TokenStorage());
  sl.registerLazySingleton(() => ApiClient(tokens: sl(), baseUrl: apiBase));
  sl.registerLazySingleton(() => AuthBloc(api: sl(), tokens: sl()));
}
