import 'dart:async';

import 'package:inventory_app/data/repositories/item_repository.dart';
import 'package:inventory_app/models/inventory_item.dart';

/// In-memory `ItemRepository` for provider/widget tests, so they don't
/// have to spin up drift or the `path_provider` plugin.
class FakeItemRepository implements ItemRepository {
  final _items = <String, InventoryItem>{};
  final _controller = StreamController<List<InventoryItem>>.broadcast();

  void _emit() {
    final active = _items.values.where((item) => !item.isDeleted).toList();
    _controller.add(active);
  }

  @override
  Stream<List<InventoryItem>> watchActiveItems() {
    return Stream.multi((controller) {
      final active = _items.values.where((item) => !item.isDeleted).toList();
      controller.add(active);
      final sub = _controller.stream.listen(controller.add);
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Future<void> addItem(InventoryItem item) async {
    _items[item.id] = item;
    _emit();
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    _items[item.id] = item;
    _emit();
  }

  @override
  Future<void> deleteItem(String id) async {
    final existing = _items[id];
    if (existing != null) {
      _items[id] = existing.copyWith(deletedAt: DateTime.now());
      _emit();
    }
  }

  void dispose() => _controller.close();
}
