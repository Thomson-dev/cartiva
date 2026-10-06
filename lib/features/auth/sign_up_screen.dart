import 'package:cartiva/features/auth/sign_in_screen.dart';
import 'package:cartiva/features/auth/provider/auth_provider.dart';
import 'package:cartiva/features/auth/otp_verification_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cartiva/features/home_main/home_main.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isFormValid = false;

  final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();

    ref.listenManual(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result == null) {
            return;
          }

          _showSuccess(result.requiresEmailConfirmation);
        },
        error: (error, stackTrace) {
          _showError(error.toString());
        },
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ============================================================
  // FORM STATE
  // ============================================================

  void _updateFormValidity() {
    final isValid =
        _validateName(_nameController.text) == null &&
        _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null;

    if (_isFormValid == isValid) {
      return;
    }

    setState(() {
      _isFormValid = isValid;
    });
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  void _showSuccess(bool requiresEmailConfirmation) {
    if (requiresEmailConfirmation) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              OtpVerificationScreen(email: _emailController.text.trim()),
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeMain()),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Let's create your account.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                const SizedBox(height: 24),

                // =================================================
                // NAME
                // =================================================
                const _FieldLabel('Full Name'),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (_) {
                    _updateFormValidity();
                  },
                  validator: _validateName,
                  decoration: _fieldDecoration(
                    hint: 'Enter your full name',
                    controller: _nameController,
                    validator: _validateName,
                  ),
                ),

                const SizedBox(height: 18),

                // =================================================
                // EMAIL
                // =================================================
                const _FieldLabel('Email'),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (_) {
                    _updateFormValidity();
                  },
                  validator: _validateEmail,
                  decoration: _fieldDecoration(
                    hint: 'Enter your email address',
                    controller: _emailController,
                    validator: _validateEmail,
                  ),
                ),

                const SizedBox(height: 18),

                // =================================================
                // PASSWORD
                // =================================================
                const _FieldLabel('Password'),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (_) {
                    _updateFormValidity();
                  },
                  onFieldSubmitted: (_) {
                    if (_isFormValid && !isLoading) {
                      _submit();
                    }
                  },
                  validator: _validatePassword,
                  decoration: _fieldDecoration(
                    hint: 'Enter your password',
                    controller: _passwordController,
                    validator: _validatePassword,
                    obscureToggle: true,
                  ),
                ),

                const SizedBox(height: 18),

                const _TermsText(),

                const SizedBox(height: 20),

                // =================================================
                // CREATE ACCOUNT
                // =================================================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid && !isLoading ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create an Account',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // DIVIDER
                // =================================================
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Or',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),

                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 20),

                // =================================================
                // GOOGLE
                // =================================================
                _SocialButton(
                  label: 'Sign Up with Google',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: Colors.grey.shade300,
                  icon: const Text(
                    'G',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  onPressed: () {
                    // Google OAuth will be
                    // implemented separately.
                  },
                ),

                const SizedBox(height: 12),

                // =================================================
                // FACEBOOK
                // =================================================
                _SocialButton(
                  label: 'Sign Up with Facebook',
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                  icon: const Icon(
                    Icons.facebook,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    // Facebook OAuth will be
                    // implemented separately.
                  },
                ),

                const SizedBox(height: 20),

                // =================================================
                // LOGIN
                // =================================================
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log In',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (isLoading) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const SignIn(),
                                ),
                              );
                            },
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
    );
  }

  // ============================================================
  // FIELD DECORATION
  // ============================================================

  InputDecoration _fieldDecoration({
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureToggle = false,
  }) {
    final hasText = controller.text.isNotEmpty;

    final error = hasText ? validator(controller.text) : null;

    final isValid = hasText && error == null;

    final isInvalid = hasText && error != null;

    final borderColor = isInvalid
        ? Colors.red
        : isValid
        ? Colors.green
        : Colors.grey.shade300;

    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(color: Color(0xff999999)),

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      suffixIcon: obscureToggle
          ? IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            )
          : isValid
          ? const Icon(Icons.check_circle, color: Colors.green)
          : isInvalid
          ? const Icon(Icons.error, color: Colors.red)
          : null,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isInvalid
              ? Colors.red
              : isValid
              ? Colors.green
              : Colors.black,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),

      errorStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}

// ================================================================
// FIELD LABEL
// ================================================================

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }
}

// ================================================================
// TERMS
// ================================================================

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xff1A1A1A),
          fontSize: 14,
          height: 1.4,
        ),
        children: [
          const TextSpan(text: 'By signing up you agree to our '),

          TextSpan(
            text: 'Terms',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Terms page.
              },
          ),

          const TextSpan(text: ', '),

          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Privacy page.
              },
          ),

          const TextSpan(text: ', and '),

          TextSpan(
            text: 'Cookie Use',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Cookie page.
              },
          ),

          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

// ================================================================
// SOCIAL BUTTON
// ================================================================

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Widget icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: borderColor ?? backgroundColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,

            const SizedBox(width: 10),

            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
