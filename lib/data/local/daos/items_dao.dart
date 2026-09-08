import 'package:drift/drift.dart';

import '../database.dart';

/// A joined row: an item plus its (at most one) category-specific
/// extension row. Exactly one of [groceryDetail]/[durableGoodDetail] is
/// non-null, matching the item's category.
class ItemJoinRow {
  final Item item;
  final GroceryDetail? groceryDetail;
  final DurableGoodDetail? durableGoodDetail;

  const ItemJoinRow({
    required this.item,
    this.groceryDetail,
    this.durableGoodDetail,
  });
}

/// Data-access layer for `items` + its extension tables. Returns drift row
/// types, not domain models — mapping to `InventoryItem` happens in the
/// repository layer.
class ItemsDao {
  final AppDatabase db;

  ItemsDao(this.db);

  Stream<List<ItemJoinRow>> watchActiveItems() {
    final query = db.select(db.items).join([
      leftOuterJoin(
        db.groceryDetails,
        db.groceryDetails.itemId.equalsExp(db.items.id),
      ),
      leftOuterJoin(
        db.durableGoodDetails,
        db.durableGoodDetails.itemId.equalsExp(db.items.id),
      ),
    ])..where(db.items.deletedAt.isNull());

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ItemJoinRow(
              item: row.readTable(db.items),
              groceryDetail: row.readTableOrNull(db.groceryDetails),
              durableGoodDetail: row.readTableOrNull(db.durableGoodDetails),
            ),
          )
          .toList(),
    );
  }

  Future<void> upsertItem(ItemsCompanion item) =>
      db.into(db.items).insertOnConflictUpdate(item);

  Future<void> upsertGroceryDetail(GroceryDetailsCompanion detail) =>
      db.into(db.groceryDetails).insertOnConflictUpdate(detail);

  Future<void> upsertDurableGoodDetail(DurableGoodDetailsCompanion detail) =>
      db.into(db.durableGoodDetails).insertOnConflictUpdate(detail);

  Future<void> deleteGroceryDetail(String itemId) => (db.delete(
    db.groceryDetails,
  )..where((t) => t.itemId.equals(itemId))).go();

  Future<void> deleteDurableGoodDetail(String itemId) => (db.delete(
    db.durableGoodDetails,
  )..where((t) => t.itemId.equals(itemId))).go();

  Future<void> softDeleteItem(String id, DateTime deletedAt) =>
      (db.update(db.items)..where((t) => t.id.equals(id))).write(
        ItemsCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
        ),
      );
}
