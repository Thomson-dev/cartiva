import 'dart:async';

import 'package:cartiva/features/auth/provider/auth_provider.dart';

import 'package:cartiva/features/auth/data/auth_repository.dart';
import 'package:cartiva/features/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSignInRepository extends AuthRepository {
  FakeSignInRepository()
    : super(
        SupabaseClient(
          'https://example.com',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );

  final result = Completer<AuthResponse>();
  int calls = 0;
  String? email;
  String? password;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    calls++;
    this.email = email;
    this.password = password;
    return result.future;
  }
}

void main() {
  test(
    'provider blocks duplicate requests and rejects missing sessions',
    () async {
      final repository = FakeSignInRepository();
      final container = ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      container.listen(signInProvider, (_, _) {});
      final controller = container.read(signInProvider.notifier);
      final request = controller.signIn(
        email: ' shopper@example.com ',
        password: 'secret',
      );
      expect(container.read(signInProvider).isLoading, isTrue);
      expect(
        await controller.signIn(email: 'other@example.com', password: 'secret'),
        isFalse,
      );
      expect(repository.calls, 1);
      expect(repository.email, 'shopper@example.com');
      repository.result.complete(AuthResponse());
      expect(await request, isFalse);
      expect(container.read(signInProvider).hasError, isTrue);
      controller.clearError();
      expect(container.read(signInProvider).hasError, isFalse);
    },
  );

  test('provider ignores results after disposal', () async {
    final repository = FakeSignInRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(signInProvider, (_, _) {});
    final request = container
        .read(signInProvider.notifier)
        .signIn(email: 'shopper@example.com', password: 'secret');
    container.dispose();
    repository.result.complete(AuthResponse());
    expect(await request, isFalse);
  });

  testWidgets('validates credentials and toggles password visibility', (
    tester,
  ) async {
    final repository = FakeSignInRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SignIn()),
      ),
    );
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Please enter your email address'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    expect(repository.calls, 0);
    await tester.enterText(find.byType(TextFormField).first, 'invalid');
    await tester.pump();
    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isFalse,
    );
  });

  testWidgets('submits credentials once and allows retry after an error', (
    tester,
  ) async {
    final repository = FakeSignInRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SignIn()),
      ),
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      ' shopper@example.com ',
    );
    await tester.enterText(find.byType(TextFormField).last, ' secret ');
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(repository.email, 'shopper@example.com');
    expect(repository.password, ' secret ');
    expect(repository.calls, 1);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    repository.result.completeError(
      const AuthException(
        'Invalid login credentials',
        code: 'invalid_credentials',
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Incorrect email or password. Please try again.'),
      findsOneWidget,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });
}
