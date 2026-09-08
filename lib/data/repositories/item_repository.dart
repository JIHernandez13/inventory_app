import '../../models/inventory_item.dart';

/// Storage-agnostic interface for reading/writing inventory items.
/// `providers/` depends on this, not on drift directly, so the storage
/// backend can change without touching business logic.
abstract class ItemRepository {
  /// Reactive stream of all non-deleted items, updating as the underlying
  /// storage changes.
  Stream<List<InventoryItem>> watchActiveItems();

  /// Inserts a new item (or overwrites one with the same id).
  Future<void> addItem(InventoryItem item);

  /// Updates an existing item in place.
  Future<void> updateItem(InventoryItem item);

  /// Soft-deletes the item with the given id.
  Future<void> deleteItem(String id);
}
