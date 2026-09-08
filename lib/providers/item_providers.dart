import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/local/database.dart';
import '../data/repositories/drift_item_repository.dart';
import '../data/repositories/item_repository.dart';
import '../models/inventory_item.dart';

/// Opens (and owns) the single on-device drift database for the app's
/// lifetime.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return DriftItemRepository(ref.watch(appDatabaseProvider));
});

/// Reactive list of active (non-deleted) items, backed by drift's
/// `.watch()` — the UI updates automatically after any CRUD operation.
final itemListProvider = StreamProvider<List<InventoryItem>>((ref) {
  return ref.watch(itemRepositoryProvider).watchActiveItems();
});

const _uuid = Uuid();

/// CRUD entry point for the UI. Keeps id/timestamp bookkeeping out of
/// screens: callers pass a partially-filled draft (see
/// `InventoryItem.draft`), this notifier fills in the rest.
class ItemsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  ItemRepository get _repository => ref.read(itemRepositoryProvider);

  Future<void> addItem(InventoryItem draft) async {
    state = const AsyncValue.loading();
    final now = DateTime.now();
    final item = draft.copyWith(id: _uuid.v4(), createdAt: now, updatedAt: now);
    state = await AsyncValue.guard(() => _repository.addItem(item));
  }

  Future<void> updateItem(InventoryItem item) async {
    state = const AsyncValue.loading();
    final updated = item.copyWith(updatedAt: DateTime.now());
    state = await AsyncValue.guard(() => _repository.updateItem(updated));
  }

  Future<void> deleteItem(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteItem(id));
  }
}

final itemsNotifierProvider = NotifierProvider<ItemsNotifier, AsyncValue<void>>(
  ItemsNotifier.new,
);
