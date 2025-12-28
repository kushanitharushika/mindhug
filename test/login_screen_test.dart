import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindhug/core/theme/app_theme.dart';
import 'package:mindhug/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders fields and button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    ));

    // Verify key elements are present
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    
    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 1)); // Finish animation (if any)
    
    // Since we didn't mock navigation, we're just checking it didn't crash
  });
}
