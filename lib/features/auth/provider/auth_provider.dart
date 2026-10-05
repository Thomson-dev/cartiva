import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../model/sign_up_result.dart';

class AuthController extends AsyncNotifier<SignUpResult?> {
  @override
  Future<SignUpResult?> build() async {
    return null;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);

      final result = await repository.signUp(
        name: name,
        email: email,
        password: password,
      );

      state = AsyncData(result);
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(_mapAuthError(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError('Something went wrong. Please try again.', stackTrace);
    }
  }

  Future<AuthResponse?> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await ref
          .read(authRepositoryProvider)
          .verifyOtp(email: email, otpCode: otpCode);

      state = const AsyncData(null);
      return response;
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(_mapAuthError(error), stackTrace);
      return null;
    } catch (error, stackTrace) {
      state = AsyncError('Something went wrong. Please try again.', stackTrace);
      return null;
    }
  }

  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }

  String _mapAuthError(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('already registered')) {
      return 'An account with this email already exists.';
    }

    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('password')) {
      return 'Your password does not meet the requirements.';
    }

    if (message.contains('rate limit')) {
      return 'Too many attempts. Please try again later.';
    }

    if (message.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'Unable to create your account. Please try again.';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, SignUpResult?>(AuthController.new);



    

class SignInController extends AsyncNotifier<AuthResponse?> {
  @override
  AuthResponse? build() => null;

  Future<bool> signIn({required String email, required String password}) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();

    try {
      final response = await ref
          .read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password);
      if (!ref.mounted) return false;
      if (response.session == null) {
        throw const AuthException('Unable to sign in. Please try again.');
      }
      state = AsyncData(response);
      return true;
    } on AuthException catch (error, stackTrace) {
      if (!ref.mounted) return false;
      final message = switch (error.code) {
        'invalid_credentials' =>
          'Incorrect email or password. Please try again.',
        'email_not_confirmed' => 'Please verify your email before signing in.',
        _ => error.message,
      };
      state = AsyncError(message, stackTrace);
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncError('Unable to sign in. Please try again.', stackTrace);
    }
    return false;
  }

  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }
}

final signInProvider =
    AsyncNotifierProvider.autoDispose<SignInController, AuthResponse?>(
      SignInController.new,
    );
