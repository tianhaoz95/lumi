import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/lumi_text_field.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

/// ForgotPasswordScreen
/// - Matches design/ui_design/forgot_password/code.html (asymmetric layout)
/// - Exposes an optional [onSendReset] callback for tests/higher-layer injection.
class ForgotPasswordScreen extends StatefulWidget {
  final Future<void> Function(String email)? onSendReset;

  const ForgotPasswordScreen({Key? key, this.onSendReset}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email required';
    final emailReg = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailReg.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    setState(() => _submitting = true);
    try {
      final email = _emailController.text.trim();
      if (widget.onSendReset != null) {
        await widget.onSendReset!.call(email);
        if (mounted) setState(() => _sent = true);
        return;
      }
      // Default: call AppwriteService
      await AppwriteService.instance.sendPasswordReset(email);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e?.toString() ?? 'Failed to send reset')));
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
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Editorial left column (hidden on small widths)
                  Expanded(
                    flex: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) return const SizedBox.shrink();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.receipt_long, size: 120, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Recover access', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('We will send instructions to your email to reset your password.'),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Recovery card
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_sent)
                          Column(
                            children: const [
                              Icon(Icons.check_circle, color: Colors.green, size: 64),
                              SizedBox(height: 12),
                              Text('Check your inbox', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('We sent password reset instructions to your email.'),
                            ],
                          )
                        else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text('Forgot password', style: Theme.of(context).textTheme.headlineSmall),
                                    const SizedBox(height: 12),
                                    LumiTextField(
                                      key: const Key('forgot_email_field'),
                                      controller: _emailController,
                                      hintText: 'Email',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        key: const Key('send_reset_button'),
                                        onPressed: _submitting ? null : _submit,
                                        child: _submitting
                                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                            : const Text('Send Reset'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
