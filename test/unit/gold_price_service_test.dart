import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/gold_price_service.dart';

void main() {
  group('GoldPriceService Tests', () {
    test('getCurrentPrice should return valid price data', () async {
      // Act
      final price = await GoldPriceService.getCurrentPrice();

      // Assert
      expect(price, isNotNull);
      expect(price.price, greaterThan(0));
      expect(price.timestamp, isNotNull);
      expect(price.change, isNotNull);
      expect(price.changePercent, isNotNull);
    });

    test('price should be within realistic range', () async {
      // Act
      final price = await GoldPriceService.getCurrentPrice();

      // Assert (gold price typically between 1500-3000)
      expect(price.price, greaterThan(1500));
      expect(price.price, lessThan(3000));
    });

    test('timestamp should be recent', () async {
      // Act
      final price = await GoldPriceService.getCurrentPrice();

      // Assert (within last 5 minutes)
      final now = DateTime.now();
      final diff = now.difference(price.timestamp).inMinutes;
      expect(diff, lessThan(5));
    });
  });
}
