/// Attributes shared by the non-grocery categories (`homeGood`,
/// `appliance`, `tool`) — things you own rather than consume.
class DurableGoodAttributes {
  final String? brand;
  final String? model;
  final String? serialNumber;
  final DateTime? purchaseDate;
  final DateTime? warrantyExpiration;
  final String? warrantyProvider;
  final String? condition;

  const DurableGoodAttributes({
    this.brand,
    this.model,
    this.serialNumber,
    this.purchaseDate,
    this.warrantyExpiration,
    this.warrantyProvider,
    this.condition,
  });

  DurableGoodAttributes copyWith({
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? purchaseDate,
    DateTime? warrantyExpiration,
    String? warrantyProvider,
    String? condition,
  }) {
    return DurableGoodAttributes(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyExpiration: warrantyExpiration ?? this.warrantyExpiration,
      warrantyProvider: warrantyProvider ?? this.warrantyProvider,
      condition: condition ?? this.condition,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurableGoodAttributes &&
          runtimeType == other.runtimeType &&
          brand == other.brand &&
          model == other.model &&
          serialNumber == other.serialNumber &&
          purchaseDate == other.purchaseDate &&
          warrantyExpiration == other.warrantyExpiration &&
          warrantyProvider == other.warrantyProvider &&
          condition == other.condition;

  @override
  int get hashCode => Object.hash(
    brand,
    model,
    serialNumber,
    purchaseDate,
    warrantyExpiration,
    warrantyProvider,
    condition,
  );
}
