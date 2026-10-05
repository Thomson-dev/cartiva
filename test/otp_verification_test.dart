import 'package:cartiva/features/auth/data/auth_repository.dart';
import 'package:cartiva/features/auth/otp_verification_screen.dart';
import 'package:cartiva/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository()
    : super(
        SupabaseClient(
          'https://example.com',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );

  String? verifiedEmail;
  String? verifiedCode;
  int resendCount = 0;

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    verifiedEmail = email;
    verifiedCode = otpCode;
    throw const AuthException('This code has expired.');
  }

  @override
  Future<void> resendSignUpOtp({required String email}) async {
    resendCount++;
  }
}

void main() {
  testWidgets('validates input and displays verification errors for retry', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: OtpVerificationScreen(email: 'shopper@example.com'),
        ),
      ),
    );
    expect(find.text('shopper@example.com'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    await tester.tap(find.text('Verify Email'));
    await tester.pumpAndSettle();
    expect(repository.verifiedEmail, 'shopper@example.com');
    expect(repository.verifiedCode, '123456');
    expect(find.text('This code has expired.'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('resend waits for cooldown and restarts it after sending', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: OtpVerificationScreen(email: 'shopper@example.com'),
        ),
      ),
    );
    expect(find.text('Resend code in 60s'), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
    await tester.pump(const Duration(seconds: 60));
    await tester.ensureVisible(find.text('Resend code'));
    await tester.tap(find.text('Resend code'));
    await tester.pump();
    expect(repository.resendCount, 1);
    expect(find.text('Resend code in 60s'), findsOneWidget);
    expect(
      find.text('A new code has been sent to your email.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
