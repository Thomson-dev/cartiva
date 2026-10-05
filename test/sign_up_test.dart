import 'package:cartiva/features/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reload action refreshes the sign-up screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignUp()));

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.byTooltip('Reload sign-up form'), findsOneWidget);

    await tester.tap(find.byTooltip('Reload sign-up form'));
    await tester.pump();

    expect(find.text('Create an account'), findsOneWidget);
  });
}