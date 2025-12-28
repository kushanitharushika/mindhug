import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindhug/core/theme/app_theme.dart';
import 'package:mindhug/screens/profile/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders key features', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: const ProfileScreen(),
    ));

    // Verify key elements are present
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Retake\nAssessment'), findsOneWidget);
    expect(find.text('Crisis\nHelpline'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    
    // Check if Switch exists (Theme Toggle)
    expect(find.byType(Switch), findsOneWidget);
    
    // Tap Crisis Helpline
    await tester.tap(find.text('Crisis\nHelpline'));
    await tester.pumpAndSettle();
    
    // Verify Dialog appears
    expect(find.text('Crisis Helplines'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
