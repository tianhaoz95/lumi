import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/auth_notifier.dart';

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier();

  void notifyAuthChanged() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier();

  // When auth state changes, notify the GoRouter to reevaluate redirects.
  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    notifier.notifyAuthChanged();
  });

  ref.onDispose(() => notifier.dispose());

  return GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/',
    refreshListenable: notifier,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);
      final loggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.location == '/login';

      if (!loggedIn && !isLoggingIn) return '/login';
      if (loggedIn && isLoggingIn) return '/';
      return null;
    },
  );
});
