class SignUpResult {
  final String userId;
  final String? email;
  final bool requiresEmailConfirmation;

  const SignUpResult({
    required this.userId,
    required this.email,
    required this.requiresEmailConfirmation,
  });
}