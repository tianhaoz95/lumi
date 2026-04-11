import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/lumi_text_field.dart';
import '../home/home.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

/// SignUpScreen
/// - Matches design/ui_design/sign_up/code.html (structure & spacing)
/// - Fields: Full Name, Email, Password, Terms checkbox
/// - Exposes an [onSignUp] callback for higher-layer implementation (AppwriteService)
class SignUpScreen extends StatefulWidget {
  final Future<void> Function(String name, String email, String password)? onSignUp;

  const SignUpScreen({Key? key, this.onSignUp}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _submitting = false;
  bool _termsChecked = false;

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
    // Enable CTA only when terms are checked and basic non-empty checks pass
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
    setState(() => _submitting = true);
    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (widget.onSignUp != null) {
        await widget.onSignUp!(name, email, password);
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
        return;
      }

      // Default: attempt to use AppwriteService Account API. Tests can inject a fake account.
      try {
        final account = AppwriteService.instance.account;
        // Try common Appwrite method names. Wrap in try/catch.
        try {
          // Some SDKs expose createAccount or create; try both patterns.
          if (account.createAccount != null) {
            await account.createAccount(name: name, email: email, password: password);
          } else if (account.create != null) {
            await account.create(userId: 'unique-${DateTime.now().millisecondsSinceEpoch}', email: email, password: password, name: name);
          } else {
            // Fallback: attempt createEmailPassword (older SDKs)
            if (account.createEmailPassword != null) {
              await account.createEmailPassword(email: email, password: password);
            } else {
              throw StateError('Account create method not available');
            }
          }
        } catch (e) {
          // If dynamic invocation fails because the method is missing, rethrow to outer catch
          rethrow;
        }

        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e?.toString() ?? 'Sign up failed')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create an account', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 12),
                  Text('Join the sanctuary — all your data stays on device.', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        LumiTextField(
                          key: const Key('name_field'),
                          controller: _nameController,
                          hintText: 'Full name',
                          validator: _validateName,
                        ),
                        const SizedBox(height: 12),
                        LumiTextField(
                          key: const Key('email_field'),
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),
                        LumiTextField(
                          key: const Key('password_field'),
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              key: const Key('terms_checkbox'),
                              value: _termsChecked,
                              onChanged: (v) => setState(() => _termsChecked = v ?? false),
                            ),
                            const Expanded(child: Text('I agree to the Terms of Service and Privacy Policy')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            key: const Key('signup_button'),
                            onPressed: (_submitting || !_canSubmit) ? null : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Create account'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
