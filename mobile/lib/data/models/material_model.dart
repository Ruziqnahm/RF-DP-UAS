class PrintMaterial {
  final int id;
  final int productId;
  final String name;
  final double priceMultiplier;
  final String? description;
  final bool isActive;

  PrintMaterial({
    required this.id,
    required this.productId,
    required this.name,
    required this.priceMultiplier,
    this.description,
    this.isActive = true,
  });

  factory PrintMaterial.fromJson(Map<String, dynamic> json) {
    return PrintMaterial(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      priceMultiplier: (json['price_multiplier'] ?? 1.0).toDouble(),
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  double get pricePerSqm => 0.0;

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
  static List<PrintMaterial> getDummyMaterials() {
    return [
      // Banner Materials (Product ID 1)
      PrintMaterial(
        id: 1,
        productId: 1,
        name: 'Flexi China 280gr',
        priceMultiplier: 0.8, // ~16k/m
        description:
            'Bahan standar, permukaan agak kasar, cocok untuk jangka pendek.',
      ),
      PrintMaterial(
        id: 2,
        productId: 1,
        name: 'Flexi Korea 440gr',
        priceMultiplier: 1.3, // ~26k/m
        description: 'Bahan tebal, halus, tahan lama, cocok untuk outdoor.',
      ),
      PrintMaterial(
        id: 3,
        productId: 1,
        name: 'Albatross',
        priceMultiplier: 2.5, // ~50k/m
        description:
            'Bahan halus seperti kertas foto, cocok untuk X-Banner/Indoor.',
      ),

      // Sticker Materials (Product ID 2)
      PrintMaterial(
        id: 4,
        productId: 2,
        name: 'Vinyl Standard (Ritrama)',
        priceMultiplier: 1.0,
        description: 'Stiker vinyl standar, tahan air & panas.',
      ),
      PrintMaterial(
        id: 5,
        productId: 2,
        name: 'Vinyl Transparan',
        priceMultiplier: 1.2,
        description: 'Stiker bening, cocok untuk botol/gelas.',
      ),
      PrintMaterial(
        id: 6,
        productId: 2,
        name: 'Chromo',
        priceMultiplier: 0.5,
        description: 'Stiker berbahan kertas licin, tidak tahan air.',
      ),

      // Kartu Nama (Product ID 3)
      PrintMaterial(
        id: 7,
        productId: 3,
        name: 'Art Carton 260gr',
        priceMultiplier: 1.0,
        description: 'Standar kartu nama.',
      ),
      PrintMaterial(
        id: 8,
        productId: 3,
        name: 'BW (Blues White)',
        priceMultiplier: 1.2,
        description: 'Kertas tebal bertekstur, bisa ditulis.',
      ),
    ];
  }
}
