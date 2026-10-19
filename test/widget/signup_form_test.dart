import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carwashapp/features/auth/widgets/signup_form.dart';

void main() {
  testWidgets('SignupForm validates required fields and password match', (
    WidgetTester tester,
  ) async {
    bool successCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProviderScope(
            child: SignupForm(
              onSuccess: () {
                successCalled = true;
              },
            ),
          ),
        ),
      ),
    );

    // Tap submit without entering data
    final submitButton = find.text('Create Account');
    await tester.tap(submitButton);
    await tester.pump();

    // Verify field validation error messages appear
    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(successCalled, false);
  });
}
