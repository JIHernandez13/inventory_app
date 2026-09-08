import 'package:drift/drift.dart' show Value;

import '../../models/durable_good_attributes.dart';
import '../../models/grocery_attributes.dart';
import '../../models/inventory_item.dart';
import '../../models/item_category.dart';
import '../local/daos/items_dao.dart';
import '../local/database.dart';
import 'item_repository.dart';

/// Recognizable exception type for local-storage failures, so raw
/// drift/sqlite3 exceptions never leak into `providers/`/`presentation/`.
class ItemStorageException implements Exception {
  final String message;
  final Object? cause;

  ItemStorageException(this.message, [this.cause]);

  @override
  String toString() =>
      'ItemStorageException: $message${cause != null ? ' ($cause)' : ''}';
}

class DriftItemRepository implements ItemRepository {
  final ItemsDao _dao;

  DriftItemRepository(AppDatabase database) : _dao = ItemsDao(database);

  @override
  Stream<List<InventoryItem>> watchActiveItems() {
    return _dao
        .watchActiveItems()
        .map((rows) => rows.map(_toDomain).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw ItemStorageException('Failed to watch items', error);
        });
  }

  @override
  Future<void> addItem(InventoryItem item) => _persist(item);

  @override
  Future<void> updateItem(InventoryItem item) => _persist(item);

  Future<void> _persist(InventoryItem item) async {
    try {
      await _dao.upsertItem(
        ItemsCompanion.insert(
          id: item.id,
          category: item.category,
          name: item.name,
          quantity: Value(item.quantity),
          location: Value(item.location),
          notes: Value(item.notes),
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
          deletedAt: Value(item.deletedAt),
        ),
      );

      if (item.category == ItemCategory.grocery) {
        final attrs = item.groceryAttributes ?? const GroceryAttributes();
        await _dao.upsertGroceryDetail(
          GroceryDetailsCompanion.insert(
            itemId: item.id,
            expirationDate: Value(attrs.expirationDate),
            perishable: Value(attrs.perishable),
            purchaseDate: Value(attrs.purchaseDate),
            unitOfMeasure: Value(attrs.unitOfMeasure),
            lowStockThreshold: Value(attrs.lowStockThreshold),
          ),
        );
        await _dao.deleteDurableGoodDetail(item.id);
      } else {
        final attrs =
            item.durableGoodAttributes ?? const DurableGoodAttributes();
        await _dao.upsertDurableGoodDetail(
          DurableGoodDetailsCompanion.insert(
            itemId: item.id,
            brand: Value(attrs.brand),
            model: Value(attrs.model),
            serialNumber: Value(attrs.serialNumber),
            purchaseDate: Value(attrs.purchaseDate),
            warrantyExpiration: Value(attrs.warrantyExpiration),
            warrantyProvider: Value(attrs.warrantyProvider),
            condition: Value(attrs.condition),
          ),
        );
        await _dao.deleteGroceryDetail(item.id);
      }
    } catch (error) {
      throw ItemStorageException('Failed to save item ${item.id}', error);
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await _dao.softDeleteItem(id, DateTime.now());
    } catch (error) {
      throw ItemStorageException('Failed to delete item $id', error);
    }
  }

  InventoryItem _toDomain(ItemJoinRow row) {
    final item = row.item;
    final groceryDetail = row.groceryDetail;
    final durableGoodDetail = row.durableGoodDetail;

    return InventoryItem(
      id: item.id,
      category: item.category,
      name: item.name,
      quantity: item.quantity,
      location: item.location,
      notes: item.notes,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      deletedAt: item.deletedAt,
      groceryAttributes: groceryDetail == null
          ? null
          : GroceryAttributes(
              expirationDate: groceryDetail.expirationDate,
              perishable: groceryDetail.perishable,
              purchaseDate: groceryDetail.purchaseDate,
              unitOfMeasure: groceryDetail.unitOfMeasure,
              lowStockThreshold: groceryDetail.lowStockThreshold,
            ),
      durableGoodAttributes: durableGoodDetail == null
          ? null
          : DurableGoodAttributes(
              brand: durableGoodDetail.brand,
              model: durableGoodDetail.model,
              serialNumber: durableGoodDetail.serialNumber,
              purchaseDate: durableGoodDetail.purchaseDate,
              warrantyExpiration: durableGoodDetail.warrantyExpiration,
              warrantyProvider: durableGoodDetail.warrantyProvider,
              condition: durableGoodDetail.condition,
            ),
    );
  }
}
