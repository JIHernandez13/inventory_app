/// Attributes specific to `ItemCategory.grocery` items.
class GroceryAttributes {
  /// When this item expires, if known.
  final DateTime? expirationDate;

  /// Whether this item spoils (as opposed to shelf-stable goods).
  final bool perishable;

  /// When this item was purchased, if known.
  final DateTime? purchaseDate;

  /// Free-text unit of measure (e.g. "oz", "count", "lb").
  final String? unitOfMeasure;

  /// Quantity at or below which this item is considered low stock.
  /// Null means low-stock tracking is disabled for this item.
  final int? lowStockThreshold;

  const GroceryAttributes({
    this.expirationDate,
    this.perishable = false,
    this.purchaseDate,
    this.unitOfMeasure,
    this.lowStockThreshold,
  });

  GroceryAttributes copyWith({
    DateTime? expirationDate,
    bool? perishable,
    DateTime? purchaseDate,
    String? unitOfMeasure,
    int? lowStockThreshold,
  }) {
    return GroceryAttributes(
      expirationDate: expirationDate ?? this.expirationDate,
      perishable: perishable ?? this.perishable,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryAttributes &&
          runtimeType == other.runtimeType &&
          expirationDate == other.expirationDate &&
          perishable == other.perishable &&
          purchaseDate == other.purchaseDate &&
          unitOfMeasure == other.unitOfMeasure &&
          lowStockThreshold == other.lowStockThreshold;

  @override
  int get hashCode => Object.hash(
    expirationDate,
    perishable,
    purchaseDate,
    unitOfMeasure,
    lowStockThreshold,
  );
}
