import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? error;

  const AuthState._({required this.status, this.error});

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);
  const AuthState.error(String message) : this._(status: AuthStatus.error, error: message);

  AuthState copyWith({AuthStatus? status, String? error}) => AuthState._(
        status: status ?? this.status,
        error: error ?? this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      await AppwriteService.instance.login(email, password);
      state = const AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signup(String name, String email, String password) async {
    state = const AuthState.loading();
    try {
      await AppwriteService.instance.signup(name, email, password);
      await AppwriteService.instance.login(email, password);
      state = const AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await AppwriteService.instance.logout();
      state = const AuthState.initial();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
