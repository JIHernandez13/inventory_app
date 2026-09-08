import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/data/local/database.dart';
import 'package:inventory_app/data/repositories/drift_item_repository.dart';
import 'package:inventory_app/models/durable_good_attributes.dart';
import 'package:inventory_app/models/grocery_attributes.dart';
import 'package:inventory_app/models/inventory_item.dart';
import 'package:inventory_app/models/item_category.dart';

void main() {
  late AppDatabase database;
  late DriftItemRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftItemRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  InventoryItem grocery({String id = 'g1'}) {
    final now = DateTime(2026, 1, 1);
    return InventoryItem(
      id: id,
      category: ItemCategory.grocery,
      name: 'Milk',
      quantity: 2,
      location: 'Fridge',
      createdAt: now,
      updatedAt: now,
      groceryAttributes: const GroceryAttributes(
        perishable: true,
        unitOfMeasure: 'gal',
        lowStockThreshold: 1,
      ),
    );
  }

  InventoryItem tool({String id = 't1'}) {
    final now = DateTime(2026, 1, 1);
    return InventoryItem(
      id: id,
      category: ItemCategory.tool,
      name: 'Drill',
      quantity: 1,
      createdAt: now,
      updatedAt: now,
      durableGoodAttributes: const DurableGoodAttributes(brand: 'Acme'),
    );
  }

  test('addItem persists a grocery item with its attributes', () async {
    await repository.addItem(grocery());

    final items = await repository.watchActiveItems().first;

    expect(items, hasLength(1));
    expect(items.single.name, 'Milk');
    expect(items.single.location, 'Fridge');
    expect(items.single.groceryAttributes?.unitOfMeasure, 'gal');
    expect(items.single.durableGoodAttributes, isNull);
  });

  test('addItem persists a durable good item with its attributes', () async {
    await repository.addItem(tool());

    final items = await repository.watchActiveItems().first;

    expect(items.single.durableGoodAttributes?.brand, 'Acme');
    expect(items.single.groceryAttributes, isNull);
  });

  test('updateItem overwrites fields and attributes', () async {
    await repository.addItem(grocery());

    final updated = (await repository.watchActiveItems().first).single.copyWith(
      quantity: 10,
      groceryAttributes: const GroceryAttributes(lowStockThreshold: 5),
    );
    await repository.updateItem(updated);

    final items = await repository.watchActiveItems().first;
    expect(items.single.quantity, 10);
    expect(items.single.groceryAttributes?.lowStockThreshold, 5);
  });

  test(
    'deleteItem soft-deletes so the item drops out of active items',
    () async {
      await repository.addItem(grocery());
      await repository.deleteItem('g1');

      final items = await repository.watchActiveItems().first;
      expect(items, isEmpty);
    },
  );

  test('watchActiveItems reflects multiple independent items', () async {
    await repository.addItem(grocery());
    await repository.addItem(tool());

    final items = await repository.watchActiveItems().first;
    expect(items, hasLength(2));
    expect(items.map((i) => i.id), containsAll(['g1', 't1']));
  });
}
