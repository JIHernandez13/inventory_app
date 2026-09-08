/// The four kinds of items this app tracks.
///
/// Groceries have their own attribute set (`GroceryAttributes`); the other
/// three share `DurableGoodAttributes` since they're all "things you own
/// with a brand/warranty" rather than "things you consume".
enum ItemCategory {
  grocery,
  homeGood,
  appliance,
  tool;

  /// Human-readable label for UI display.
  String get displayName => switch (this) {
    ItemCategory.grocery => 'Grocery',
    ItemCategory.homeGood => 'Home Good',
    ItemCategory.appliance => 'Appliance',
    ItemCategory.tool => 'Tool',
  };

  /// Whether this category stores its extra attributes in
  /// `durable_good_details` rather than `grocery_details`.
  bool get isDurableGood => this != ItemCategory.grocery;
}
