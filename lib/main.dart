import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/router/app_router.dart';
import 'core/theme/dark_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '1080534072165-709kvvjk4c8cinkce9lfpufufk6038lu.apps.googleusercontent.com',
  );

  runApp(const ProviderScope(child: FoverApp()));
}

class FoverApp extends ConsumerWidget {
  const FoverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fover',
      theme: darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
