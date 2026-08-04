import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/router/app_router.dart';
import 'core/theme/dark_theme.dart';
import 'features/ads/config/providers/ads_config_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '1080534072165-709kvvjk4c8cinkce9lfpufufk6038lu.apps.googleusercontent.com',
  );

  runApp(const ProviderScope(child: FoverApp()));
}

class FoverApp extends ConsumerStatefulWidget {
  const FoverApp({super.key});

  @override
  ConsumerState<FoverApp> createState() => _FoverAppState();
}

class _FoverAppState extends ConsumerState<FoverApp> {
  bool _adsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_adsInitialized && mounted) {
        _adsInitialized = true;
        await ref.read(adsConfigProvider.notifier).initializeAdsFromConfig();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fover',
      theme: darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
