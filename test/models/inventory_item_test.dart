import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/models/grocery_attributes.dart';
import 'package:inventory_app/models/inventory_item.dart';
import 'package:inventory_app/models/item_category.dart';

InventoryItem _grocery({
  DateTime? expirationDate,
  int quantity = 5,
  int? lowStockThreshold,
}) {
  final now = DateTime(2026, 1, 1);
  return InventoryItem(
    id: 'item-1',
    category: ItemCategory.grocery,
    name: 'Milk',
    quantity: quantity,
    createdAt: now,
    updatedAt: now,
    groceryAttributes: GroceryAttributes(
      expirationDate: expirationDate,
      lowStockThreshold: lowStockThreshold,
    ),
  );
}

void main() {
  group('isExpired', () {
    test('false when there is no expiration date', () {
      expect(_grocery().isExpired, isFalse);
    });

    test('true when the expiration date has passed', () {
      final item = _grocery(
        expirationDate: DateTime(2026, 1, 1).subtract(const Duration(days: 1)),
      );
      expect(item.isExpired, isTrue);
    });

    test('false when the expiration date is in the future', () {
      final item = _grocery(
        expirationDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(item.isExpired, isFalse);
    });
  });

  group('isExpiringSoon', () {
    test('false when there is no expiration date', () {
      expect(_grocery().isExpiringSoon(), isFalse);
    });

    test('true when the expiration date is within the window', () {
      final now = DateTime(2026, 6, 1);
      final item = _grocery(expirationDate: now.add(const Duration(days: 2)));
      expect(
        item.isExpiringSoon(within: const Duration(days: 3), now: now),
        isTrue,
      );
    });

    test('false when the expiration date is beyond the window', () {
      final now = DateTime(2026, 6, 1);
      final item = _grocery(expirationDate: now.add(const Duration(days: 10)));
      expect(
        item.isExpiringSoon(within: const Duration(days: 3), now: now),
        isFalse,
      );
    });

    test('false once the expiration date has already passed', () {
      final now = DateTime(2026, 6, 1);
      final item = _grocery(
        expirationDate: now.subtract(const Duration(days: 1)),
      );
      expect(item.isExpiringSoon(now: now), isFalse);
    });
  });

  group('isLowStock', () {
    test('false when no threshold is configured', () {
      expect(_grocery(quantity: 0).isLowStock, isFalse);
    });

    test('true when quantity is at or below the threshold', () {
      expect(_grocery(quantity: 2, lowStockThreshold: 2).isLowStock, isTrue);
    });

    test('false when quantity is above the threshold', () {
      expect(_grocery(quantity: 5, lowStockThreshold: 2).isLowStock, isFalse);
    });
  });

  test('copyWith clearLocation/clearNotes actually clear the field', () {
    final item = _grocery().copyWith(location: 'Pantry', notes: 'Buy more');
    final cleared = item.copyWith(clearLocation: true, clearNotes: true);

    expect(cleared.location, isNull);
    expect(cleared.notes, isNull);
  });
}
