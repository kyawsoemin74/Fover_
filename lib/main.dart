import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/dark_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.initialize();

  runApp(
    const ProviderScope(child: FoverApp()),
  );
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