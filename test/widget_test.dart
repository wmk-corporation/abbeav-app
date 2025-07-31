import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abbeav/view/auth/screens/display.dart';
import 'package:abbeav/view/auth/screens/sign_up_screen.dart';
import 'package:abbeav/view/home/screens/home_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen displays main texts and Get Started button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DisplayScreen(),
        ),
      );

      expect(find.text('Never Miss'), findsOneWidget);
      expect(find.text('New Movies & Series'), findsOneWidget);
      expect(find.textContaining('Be the first one'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Tapping Get Started navigates to RegisterScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DisplayScreen(),
        ),
      );

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('RegisterScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Ajoute ici des vérifications spécifiques à ton RegisterScreen si besoin
      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen displays main sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Latests'), findsOneWidget);
      expect(find.text('Popular Actors'), findsOneWidget);
      expect(find.text('Trending'), findsOneWidget);
    });
  });
}
