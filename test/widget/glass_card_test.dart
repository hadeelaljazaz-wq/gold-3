import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/widgets/glass_card.dart';

void main() {
  group('GlassCard Widget Tests', () {
    testWidgets('should render child widget', (WidgetTester tester) async {
      // Arrange
      const testText = 'Test Content';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text(testText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      // Arrange
      const customPadding = EdgeInsets.all(32);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              padding: customPadding,
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Assert
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(GlassCard),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, customPadding);
    });

    testWidgets('should render with default properties',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GlassCard), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
