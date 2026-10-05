import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/sign_up_result.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Future<SignUpResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    print(response.user);
    final user = response.user;

    if (user == null) {
      throw const AuthException(
        'Unable to create your account. Please try again.',
      );
    }

    return SignUpResult(
      userId: user.id,
      email: user.email,
      requiresEmailConfirmation: response.session == null,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> resendSignUpOtp({required String email}) async {
    await _supabase.auth.resend(email: email, type: OtpType.signup);
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: otpCode,
      type: OtpType.email,
    );
  }
}
