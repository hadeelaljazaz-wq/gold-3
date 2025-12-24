# 🧪 Testing Guide - Gold Nightmare Pro

## 📋 Overview

This directory contains comprehensive tests for the Gold Nightmare Pro application, ensuring code quality, reliability, and maintainability.

## 🗂️ Test Structure

```
test/
├── unit/              # Unit tests for business logic
│   ├── gold_price_service_test.dart
│   └── trade_record_test.dart
├── widget/            # Widget tests for UI components
│   └── glass_card_test.dart
├── integration/       # Integration tests (end-to-end)
└── README.md         # This file
```

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/gold_price_service_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

## 📊 Test Coverage Goals

- **Unit Tests**: 80%+ coverage
- **Widget Tests**: 70%+ coverage
- **Integration Tests**: Critical user flows

## ✅ Current Test Status

### Unit Tests (2/10)
- ✅ GoldPriceService
- ✅ TradeRecord
- ⏳ ScalpingEngineV2
- ⏳ SwingEngineV2
- ⏳ GoldenNightmareEngine
- ⏳ ChartDataProvider
- ⏳ TradeHistoryProvider
- ⏳ NotificationService

### Widget Tests (1/10)
- ✅ GlassCard
- ⏳ TradeCard
- ⏳ StatisticsCard
- ⏳ CandlestickChart
- ⏳ IndicatorsChart
- ⏳ AnalysisScreen
- ⏳ RoyalAnalysisScreen
- ⏳ ChartsScreen
- ⏳ TradeHistoryScreen
- ⏳ SettingsScreen

### Integration Tests (0/5)
- ⏳ Full analysis flow
- ⏳ Trade creation and management
- ⏳ Settings persistence
- ⏳ Notification system
- ⏳ Chart interactions

## 🎯 Testing Best Practices

### 1. Unit Tests
- Test business logic in isolation
- Mock external dependencies
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

```dart
test('should calculate profit correctly for BUY trade', () {
  // Arrange
  final trade = TradeRecord.fromSignal(...);
  
  // Act
  final closedTrade = trade.close(exitPrice: 2653.50);
  
  // Assert
  expect(closedTrade.profitLoss, 3.50);
  expect(closedTrade.isProfitable, true);
});
```

### 2. Widget Tests
- Test UI components in isolation
- Verify widget rendering
- Test user interactions
- Check widget state changes

```dart
testWidgets('should render child widget', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: GlassCard(child: Text('Test')),
    ),
  );
  
  expect(find.text('Test'), findsOneWidget);
});
```

### 3. Integration Tests
- Test complete user flows
- Verify feature interactions
- Use realistic test data
- Test on real devices/emulators

## 📝 Writing New Tests

### 1. Create Test File
```bash
# For unit test
touch test/unit/my_service_test.dart

# For widget test
touch test/widget/my_widget_test.dart
```

### 2. Import Required Packages
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/...';
```

### 3. Write Test Groups
```dart
void main() {
  group('MyService Tests', () {
    test('should do something', () {
      // Test implementation
    });
  });
}
```

## 🔧 Mocking

### Using Mockito
```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GoldPriceService])
void main() {
  late MockGoldPriceService mockService;
  
  setUp(() {
    mockService = MockGoldPriceService();
  });
  
  test('should use mocked service', () {
    when(mockService.getCurrentPrice())
        .thenAnswer((_) async => GoldPrice(...));
    
    // Test implementation
  });
}
```

## 🐛 Debugging Tests

### Run Tests in Debug Mode
```bash
flutter test --debug
```

### Print Debug Information
```dart
test('my test', () {
  debugPrint('Debug info: $value');
  expect(value, expected);
});
```

## 📈 Continuous Integration

Tests are automatically run on:
- Every commit
- Pull requests
- Before deployment

## 🎓 Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing Guide](https://flutter.dev/docs/cookbook/testing/widget/introduction)
- [Integration Testing Guide](https://flutter.dev/docs/testing/integration-tests)

## 📞 Support

For testing questions or issues:
- Check existing tests for examples
- Review Flutter testing documentation
- Ask the development team

---

**Last Updated**: Dec 04, 2025  
**Test Coverage**: ~15% (Target: 80%)  
**Status**: 🟡 In Progress
