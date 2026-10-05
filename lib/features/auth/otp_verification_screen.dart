import 'dart:async';

import 'package:cartiva/features/auth/provider/auth_provider.dart';
import 'package:cartiva/features/auth/sign_up_screen.dart';
import 'package:cartiva/features/home_main/home_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsRemaining = 60;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  bool get _busy => _verifying || _resending;
  bool get _validCode => RegExp(r'^\d{6,10}$').hasMatch(_codeController.text);

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _resendTimer?.cancel();
    _secondsRemaining = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsRemaining--);
      if (_secondsRemaining == 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_busy || !_validCode) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final response = await ref
          .read(authRepositoryProvider)
          .verifyOtp(email: widget.email, otpCode: _codeController.text);
      if (response.session == null) {
        throw const AuthException('Verification failed. Please try again.');
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeMain()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Unable to verify your code. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_busy || _secondsRemaining > 0) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .resendSignUpOtp(email: widget.email);
      if (!mounted) return;
      _codeController.clear();
      setState(_startCooldown);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new code has been sent to your email.'),
        ),
      );
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to send a new code. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to sign up',
          onPressed: _busy
              ? null
              : () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignUp()),
                  );
                },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 48),
              const SizedBox(height: 24),
              const Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the verification code sent to',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verification code',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: 'Enter code',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    letterSpacing: 0,
                    color: Color(0xFF999999),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _verify(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validCode && !_busy ? _verify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _verifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify Email',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Didn't receive a code?",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: !_busy && _secondsRemaining == 0 ? _resend : null,
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: Text(
                    _resending
                        ? 'Sending code…'
                        : _secondsRemaining > 0
                        ? 'Resend code in ${_secondsRemaining}s'
                        : 'Resend code',
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Check your spam folder, too.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
