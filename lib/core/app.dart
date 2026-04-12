import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';
import 'lumi_animations.dart';
import '../shared/providers/model_ready_provider.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: LumiAnimations.driftDuration);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final modelReadyAsync = ref.watch(modelReadyProvider);

    // While models are loading, show a simple splash/loading screen.
    if (modelReadyAsync.isLoading) {
      return MaterialApp(
        title: 'Lumi',
        theme: getLumiTheme(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // When models are ready, animate a 500ms fade into the real app (router).
    if (modelReadyAsync.asData?.value == true) {
      _fadeController.forward();
    }

    return FadeTransition(
      opacity: _fadeController.drive(CurveTween(curve: Curves.easeOut)),
      child: MaterialApp.router(
        title: 'Lumi',
        theme: getLumiTheme(),
        routerConfig: router,
      ),
    );
  }
}
