import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/item_category.dart';

part 'database.g.dart';

/// Base fields shared by every tracked item, regardless of category.
/// Category-specific data lives in [GroceryDetails] or
/// [DurableGoodDetails] rather than as extra nullable columns here.
@DataClassName('Item')
class Items extends Table {
  /// Client-generated UUID (v4), not an autoincrement int, so ids stay
  /// stable if cloud sync is added later.
  TextColumn get id => text()();

  TextColumn get category => textEnum<ItemCategory>()();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Soft-delete marker so a future sync engine has something to
  /// reconcile; null means the item is active.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Extra attributes for `ItemCategory.grocery` items.
@DataClassName('GroceryDetail')
class GroceryDetails extends Table {
  TextColumn get itemId => text().references(Items, #id)();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  BoolColumn get perishable => boolean().withDefault(const Constant(false))();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  TextColumn get unitOfMeasure => text().nullable()();
  IntColumn get lowStockThreshold => integer().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

/// Extra attributes shared by the non-grocery categories (`homeGood`,
/// `appliance`, `tool`).
@DataClassName('DurableGoodDetail')
class DurableGoodDetails extends Table {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get serialNumber => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  DateTimeColumn get warrantyExpiration => dateTime().nullable()();
  TextColumn get warrantyProvider => text().nullable()();
  TextColumn get condition => text().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

@DriftDatabase(tables: [Items, GroceryDetails, DurableGoodDetails])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'inventory_app.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
