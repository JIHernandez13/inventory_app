import 'durable_good_attributes.dart';
import 'grocery_attributes.dart';
import 'item_category.dart';

/// A single tracked item: a grocery, home good, appliance, or tool.
///
/// Base fields are shared by every category; category-specific data lives
/// in [groceryAttributes] (only for [ItemCategory.grocery]) or
/// [durableGoodAttributes] (for the other three categories) rather than as
/// extra nullable fields on this class.
class InventoryItem {
  /// Client-generated UUID (v4) — not a DB autoincrement int, so ids stay
  /// stable if cloud sync is added later.
  final String id;

  final ItemCategory category;
  final String name;
  final int quantity;
  final String? location;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft-delete marker. Null means the item is active.
  final DateTime? deletedAt;

  final GroceryAttributes? groceryAttributes;
  final DurableGoodAttributes? durableGoodAttributes;

  const InventoryItem({
    required this.id,
    required this.category,
    required this.name,
    required this.quantity,
    this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.groceryAttributes,
    this.durableGoodAttributes,
  });

  /// Builds a not-yet-persisted item for a create form: [id] is a
  /// placeholder and timestamps are "now" — both get overwritten by
  /// `ItemsNotifier.addItem` when the item is actually saved.
  InventoryItem.draft({
    required this.category,
    required this.name,
    this.quantity = 1,
    this.location,
    this.notes,
    this.groceryAttributes,
    this.durableGoodAttributes,
  }) : id = '',
       createdAt = DateTime.now(),
       updatedAt = DateTime.now(),
       deletedAt = null;

  bool get isDeleted => deletedAt != null;

  /// True once the grocery's expiration date has passed. Always false for
  /// items without a known expiration date, or non-grocery items.
  bool get isExpired {
    final expiration = groceryAttributes?.expirationDate;
    if (expiration == null) return false;
    return expiration.isBefore(DateTime.now());
  }

  /// True when the grocery's expiration date is within [within] of now,
  /// but hasn't passed yet. Pass [now] to make the check deterministic in
  /// tests.
  bool isExpiringSoon({
    Duration within = const Duration(days: 3),
    DateTime? now,
  }) {
    final expiration = groceryAttributes?.expirationDate;
    if (expiration == null) return false;
    final reference = now ?? DateTime.now();
    if (expiration.isBefore(reference)) return false;
    return expiration.difference(reference) <= within;
  }

  /// True when [quantity] is at or below the configured low-stock
  /// threshold. Always false when no threshold is set.
  bool get isLowStock {
    final threshold = groceryAttributes?.lowStockThreshold;
    if (threshold == null) return false;
    return quantity <= threshold;
  }

  InventoryItem copyWith({
    String? id,
    ItemCategory? category,
    String? name,
    int? quantity,
    String? location,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearLocation = false,
    bool clearNotes = false,
    bool clearDeletedAt = false,
    GroceryAttributes? groceryAttributes,
    DurableGoodAttributes? durableGoodAttributes,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      location: clearLocation ? null : (location ?? this.location),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      groceryAttributes: groceryAttributes ?? this.groceryAttributes,
      durableGoodAttributes:
          durableGoodAttributes ?? this.durableGoodAttributes,
    );
  }
}
