import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/router/app_router.dart';
import 'package:ctrlhub_mobile/core/theme/app_theme.dart';
import 'package:ctrlhub_mobile/features/auth/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  final authBloc = sl<AuthBloc>()..add(const AuthStarted());
  runApp(CtrlHubApp(authBloc: authBloc));
}

class CtrlHubApp extends StatelessWidget {
  const CtrlHubApp({super.key, required this.authBloc});

  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    final router = createRouter(authBloc);
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'CtrlHub',
        theme: buildAppTheme(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
