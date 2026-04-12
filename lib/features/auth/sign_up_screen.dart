import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/lumi_text_field.dart';
import '../../shared/widgets/kit_ghost.dart';
import '../../shared/widgets/lumi_buttons.dart';
import '../../shared/widgets/atmospheric_background.dart';
import 'auth_notifier.dart';

/// SignUpScreen
/// - Matches design/ui_design/sign_up/code.html (structure & spacing)
/// - Fields: Full Name, Email, Password, Terms checkbox
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _termsChecked = false;
  bool _hasFocus = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name required';
    return null;
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

  bool get _canSubmit {
    return _termsChecked &&
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    if (!_termsChecked) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authNotifierProvider.notifier).signup(name, email, password);

    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error ?? 'Sign up failed')),
        );
      }
    }
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
                const Positioned.fill(child: AtmosphericBackground()),
                Positioned(
                  left: wide ? 12 : 24,
                  top: wide ? 36 : 20,
                  child: KitGhost(opacity: 0.06, size: wide ? 220.0 : 120.0),
                ),
                Center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
                      child: SingleChildScrollView(
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 64.0, top: 24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Create an account', style: Theme.of(context).textTheme.displayLarge),
                                          const SizedBox(height: 18),
                                          Text('Join the sanctuary — all your data stays on device.', style: Theme.of(context).textTheme.bodyLarge),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                      padding: EdgeInsets.all(_hasFocus ? 40.0 : 32.0),
                                      decoration: BoxDecoration(
                                        color: LumiColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Focus(
                                        onFocusChange: (f) => setState(() => _hasFocus = f),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              LumiTextField(
                                                key: const Key('name_field'),
                                                controller: _nameController,
                                                hintText: 'Full name',
                                                validator: _validateName,
                                                enabled: !isSubmitting,
                                              ),
                                              const SizedBox(height: 12),
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
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    key: const Key('terms_checkbox'),
                                                    value: _termsChecked,
                                                    onChanged: isSubmitting ? null : (v) => setState(() => _termsChecked = v ?? false),
                                                  ),
                                                  const Expanded(child: Text('I agree to the Terms of Service and Privacy Policy')),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                width: double.infinity,
                                                child: LumiPrimaryButton(
                                                  key: const Key('signup_button'),
                                                  onPressed: (isSubmitting || !_canSubmit) ? null : _submit,
                                                  child: isSubmitting
                                                      ? const SizedBox(
                                                          height: 16,
                                                          width: 16,
                                                          child: CircularProgressIndicator(strokeWidth: 2),
                                                        )
                                                      : const Text('Create account'),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              LumiTextAction(
                                                onPressed: isSubmitting ? null : () => context.go('/login'),
                                                child: const Text('Already have an account? Sign in'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('Create an account', style: Theme.of(context).textTheme.headlineLarge),
                                  const SizedBox(height: 12),
                                  Text('Join the sanctuary — all your data stays on device.', style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 24),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    padding: EdgeInsets.all(_hasFocus ? 40.0 : 32.0),
                                    decoration: BoxDecoration(
                                      color: LumiColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Focus(
                                      onFocusChange: (f) => setState(() => _hasFocus = f),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            LumiTextField(
                                              key: const Key('name_field'),
                                              controller: _nameController,
                                              hintText: 'Full name',
                                              validator: _validateName,
                                              enabled: !isSubmitting,
                                            ),
                                            const SizedBox(height: 12),
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
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  key: const Key('terms_checkbox'),
                                                  value: _termsChecked,
                                                  onChanged: isSubmitting ? null : (v) => setState(() => _termsChecked = v ?? false),
                                                ),
                                                const Expanded(child: Text('I agree to the Terms of Service and Privacy Policy')),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              width: double.infinity,
                                              child: LumiPrimaryButton(
                                                key: const Key('signup_button'),
                                                onPressed: (isSubmitting || !_canSubmit) ? null : _submit,
                                                child: isSubmitting
                                                    ? const SizedBox(
                                                        height: 16,
                                                        width: 16,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      )
                                                    : const Text('Create account'),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            LumiTextAction(
                                              onPressed: isSubmitting ? null : () => context.go('/login'),
                                              child: const Text('Already have an account? Sign in'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
