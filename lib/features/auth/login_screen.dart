import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/lumi_text_field.dart';
import 'auth_notifier.dart';

/// LoginScreen
/// - Matches design/ui_design/login/code.html (structure & spacing)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email required';
    final emailReg = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailReg.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState; 
    if (form == null) return;
    if (!form.validate()) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authNotifierProvider.notifier).login(email, password);

    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error ?? 'Login failed')),
        );
      }
    }
  }

  Widget _buildForm(bool isSubmitting) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          LumiTextField(
            key: const Key('email_field'),
            controller: _emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            enabled: !isSubmitting,
          ),
          const SizedBox(height: 12),
          LumiTextField(
            key: const Key('password_field'),
            controller: _passwordController,
            hintText: 'Password',
            obscureText: true,
            validator: _validatePassword,
            enabled: !isSubmitting,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('login_button'),
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: isSubmitting ? null : () => context.go('/signup'),
            child: const Text("Don't have an account? Create one"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isSubmitting = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: LumiColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 700;
            return Stack(
              children: [
                // KitGhost background (subtle mascot)
                Positioned(
                  left: wide ? 20 : 40,
                  top: wide ? 40 : 20,
                  child: Opacity(
                    opacity: 0.06,
                    child: Icon(Icons.pets, size: wide ? 260 : 140, color: LumiColors.primary),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: SingleChildScrollView(
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left hero area (intentional asymmetry)
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 48.0, top: 24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Welcome back', style: Theme.of(context).textTheme.displayLarge),
                                          const SizedBox(height: 18),
                                          Text('Sign in to continue to Lumi', style: Theme.of(context).textTheme.bodyLarge),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Right form area - offset and narrower
                                  Expanded(
                                    flex: 2,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.all(32.0),
                                      decoration: BoxDecoration(
                                        color: LumiColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: _buildForm(isSubmitting),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('Welcome back', style: Theme.of(context).textTheme.headlineLarge),
                                  const SizedBox(height: 12),
                                  Text('Sign in to continue to Lumi', style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 24),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    padding: const EdgeInsets.all(32.0),
                                    decoration: BoxDecoration(
                                      color: LumiColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: _buildForm(isSubmitting),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
