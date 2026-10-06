import 'package:cartiva/features/auth/provider/auth_provider.dart';
import 'package:cartiva/features/auth/sign_up_screen.dart';
import 'package:cartiva/features/home_main/home_main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool _isFormValid = false;

  final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

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

  void _updateFormValidity() {
    final isValid =
        _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null;

    if (_isFormValid == isValid) {
      return;
    }

    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(signInProvider).isLoading ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    final signedIn = await ref
        .read(signInProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted || !signedIn) return;
    TextInput.finishAutofillContext();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeMain()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInProvider);
    final isLoading = signInState.isLoading;
    final error = signInState.error?.toString();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: () {
                ref.read(signInProvider.notifier).clearError();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Let’s create your account.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    autofocus: true,
                    onChanged: (_) {
                      _updateFormValidity();
                    },
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    autocorrect: false,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: _fieldDecoration(
                      hint: 'Enter your email address',
                      controller: _emailController,
                      validator: _validateEmail,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      _updateFormValidity();
                    },
                    autofillHints: const [AutofillHints.password],
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onFieldSubmitted: (_) => _submit(),
                    validator: _validatePassword,
                    decoration: _fieldDecoration(
                      hint: 'Enter your password',
                      controller: _passwordController,
                      validator: _validatePassword,
                      obscureToggle: true,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        error,
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
                      onPressed: isLoading || !_isFormValid ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
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
                              'Login',
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
                          text: 'Join',
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
                                  builder: (_) => const SignUp(),
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
      ),
    );
  }

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
