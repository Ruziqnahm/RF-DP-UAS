class Material {
  final int id;
  final int productId;
  final String name;
  final double priceMultiplier;
  final String? description;
  final bool isActive;

  Material({
    required this.id,
    required this.productId,
    required this.name,
    required this.priceMultiplier,
    this.description,
    this.isActive = true,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      priceMultiplier: (json['price_multiplier'] ?? 1.0).toDouble(),
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  get pricePerSqm => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price_multiplier': priceMultiplier,
      'description': description,
      'is_active': isActive,
    };
  }

  // dummy data bahan cetak (fallback jika API tidak tersedia)
  static List<Material> getDummyMaterials() {
    return [
      Material(
        id: 1,
        productId: 1,
        name: 'Flexi Korea',
        priceMultiplier: 1.0,
        description: 'Bahan standar flexi korea',
      ),
      Material(
        id: 2,
        productId: 1,
        name: 'Flexi China',
        priceMultiplier: 0.8,
        description: 'Bahan ekonomis',
      ),
      Material(
        id: 3,
        productId: 1,
        name: 'Albatross',
        priceMultiplier: 1.5,
        description: 'Bahan premium',
      ),
    ];
  }
}
