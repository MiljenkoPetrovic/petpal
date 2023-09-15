import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpal/pages/auth_page.dart';
import 'package:petpal/pages/home_page.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {}

void main() {
  testWidgets('AuthPage should navigate to HomePage if user is authenticated',
      (WidgetTester tester) async {
    // Create a mock Firebase user
    final User mockUser = MockUser();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthPage(),
      ),
    );

    // Mock the FirebaseAuth.instance.authStateChanges() stream
    final Stream<User?> mockStream = Stream<User?>.value(mockUser);

    // Provide the mockStream to the FirebaseAuth.instance
    when(FirebaseAuth.instance.authStateChanges()).thenAnswer((_) => mockStream);

    await tester.pumpAndSettle();

    // Verify that the app navigated to the HomePage
    expect(find.byType(HomePage), findsOneWidget);
  });
}
