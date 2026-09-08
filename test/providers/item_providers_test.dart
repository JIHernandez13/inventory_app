import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/models/inventory_item.dart';
import 'package:inventory_app/models/item_category.dart';
import 'package:inventory_app/providers/item_providers.dart';

import '../support/fake_item_repository.dart';

void main() {
  late FakeItemRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeItemRepository();
    container = ProviderContainer(
      overrides: [itemRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    addTearDown(fakeRepository.dispose);
  });

  test('itemListProvider starts empty', () async {
    final items = await container.read(itemListProvider.future);
    expect(items, isEmpty);
  });

  test('addItem inserts and itemListProvider reflects it', () async {
    final notifier = container.read(itemsNotifierProvider.notifier);

    await notifier.addItem(
      InventoryItem.draft(category: ItemCategory.tool, name: 'Hammer'),
    );

    final items = await container.read(itemListProvider.future);
    expect(items, hasLength(1));
    expect(items.single.name, 'Hammer');
    expect(items.single.id, isNotEmpty);
  });

  test('deleteItem removes the item from itemListProvider', () async {
    final notifier = container.read(itemsNotifierProvider.notifier);
    await notifier.addItem(
      InventoryItem.draft(category: ItemCategory.tool, name: 'Hammer'),
    );
    final added = (await container.read(itemListProvider.future)).single;

    await notifier.deleteItem(added.id);
    // Let the fake repository's broadcast stream event reach the
    // provider's subscription before reading state again.
    await Future<void>.delayed(Duration.zero);

    final items = await container.read(itemListProvider.future);
    expect(items, isEmpty);
  });
}
