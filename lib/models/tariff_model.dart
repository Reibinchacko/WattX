class TariffModel {
  final String id;
  final String slabName;
  final double ratePerUnit;
  final double fixedCharge;
  final String description;

  TariffModel({
    required this.id,
    required this.slabName,
    required this.ratePerUnit,
    required this.fixedCharge,
    required this.description,
  });

  factory TariffModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return TariffModel(
      id: id,
      slabName: map['slabName'] ?? '',
      ratePerUnit: (map['ratePerUnit'] ?? 0.0).toDouble(),
      fixedCharge: (map['fixedCharge'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slabName': slabName,
      'ratePerUnit': ratePerUnit,
      'fixedCharge': fixedCharge,
      'description': description,
    };
  }
}
