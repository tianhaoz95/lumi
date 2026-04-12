import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home.dart';
import '../features/dashboard/dashboard.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/auth/auth_notifier.dart';
import '../features/settings/settings.dart';

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier();

  void notifyAuthChanged() => notifyListeners();
}

// Global navigator key used for programmatic navigation (e.g. notification deep-links)
final appNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier();

  // When auth state changes, notify the GoRouter to reevaluate redirects.
  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    try {
      notifier.notifyAuthChanged();
    } catch (_) {
      // Swallow listener exceptions to avoid breaking provider lifecycle in test environments.
    }
  });

  ref.onDispose(() {
    try {
      notifier.dispose();
    } catch (_) {
      // ignore dispose errors
    }
  });

  return GoRouter(
    navigatorKey: appNavigatorKey,
    debugLogDiagnostics: false,
    initialLocation: '/',
    refreshListenable: notifier,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // Defensive read of auth state so router redirect evaluations do not throw
      // during tests if providers are not yet fully wired.
      AuthState authState;
      try {
        authState = ref.read(authNotifierProvider);
      } catch (_) {
        authState = const AuthState.initial();
      }

      final loggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.location == '/login';
      final isSigningUp = state.location == '/signup';

      if (!loggedIn && !isLoggingIn && !isSigningUp) return '/login';
      // After successful login/signup, navigate to the user's Dashboard instead of Home
      if (loggedIn && (isLoggingIn || isSigningUp)) return '/dashboard';
      return null;
    },
  );
});
