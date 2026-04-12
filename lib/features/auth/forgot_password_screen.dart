import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/lumi_animations.dart';
import '../../shared/widgets/lumi_text_field.dart';
import '../../shared/widgets/kit_ghost.dart';
import '../../shared/widgets/lumi_buttons.dart';
import '../../shared/widgets/atmospheric_background.dart';
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
  bool _hasFocus = false;

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simplified and corrected build tree to avoid previous mismatched brackets.
    return Scaffold(
      backgroundColor: LumiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedContainer(
                duration: LumiAnimations.driftDuration,
                curve: LumiAnimations.driftCurve,
                padding: EdgeInsets.all(_hasFocus ? 40.0 : 32.0),
                decoration: BoxDecoration(
                  color: LumiColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Left editorial column (hidden on narrow widths)
                    Expanded(
                      flex: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) return const SizedBox.shrink();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              KitGhost(opacity: 0.06, size: 100.0, color: LumiColors.primary),
                              const SizedBox(height: 12),
                              const Icon(Icons.receipt_long, size: 120, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text('Recover access', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('We will send instructions to your email to reset your password.'),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Recovery area
                    Expanded(
                      flex: 1,
                      child: _sent
                          ? Column(
                              children: const [
                                Icon(Icons.check_circle, color: Colors.green, size: 64),
                                SizedBox(height: 12),
                                Text('Check your inbox', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('We sent password reset instructions to your email.'),
                              ],
                            )
                          : Form(
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
                                    child: LumiPrimaryButton(
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
