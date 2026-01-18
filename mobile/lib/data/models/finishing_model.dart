class Finishing {
  final int id;
  final int productId;
  final String name;
  final double additionalPrice;
  final String? description;
  final bool isActive;

  Finishing({
    required this.id,
    required this.productId,
    required this.name,
    required this.additionalPrice,
    this.description,
    this.isActive = true,
  });

  factory Finishing.fromJson(Map<String, dynamic> json) {
    return Finishing(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      additionalPrice: (json['additional_price'] ?? 0.0).toDouble(),
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'additional_price': additionalPrice,
      'description': description,
      'is_active': isActive,
    };
  }

  // dummy data finishing
  static List<Finishing> getDummyFinishings() {
    return [
      Finishing(
        id: 1,
        productId: 1,
        name: 'Mata Ayam (Cincin)',
        additionalPrice: 0,
        description: 'Lubang ring di setiap sudut (Gratis)',
      ),
      Finishing(
        id: 2,
        productId: 1,
        name: 'Lipat Saja',
        additionalPrice: 0,
        description: 'Dilipat rapi tanpa ring',
      ),
      Finishing(
        id: 3,
        productId: 1,
        name: 'Selongsong',
        additionalPrice: 5000,
        description: 'Lebihan bahan untuk bambu/kayu',
      ),
      Finishing(
        id: 4,
        productId: 1,
        name: 'Kolong Kayu',
        additionalPrice: 10000,
        description: 'Siap pasang dengan kayu',
      ),
      Finishing(
        id: 5,
        productId: 2, // Sticker
        name: 'Laminating Glossy',
        additionalPrice: 5000,
        description: 'Lapisan mengkilap pelindung gores',
      ),
      Finishing(
        id: 6,
        productId: 2, // Sticker
        name: 'Laminating Doff',
        additionalPrice: 5000,
        description: 'Lapisan matte pelindung gores',
      ),
      Finishing(
        id: 7,
        productId: 2, // Sticker
        name: 'Cutting Putus',
        additionalPrice: 10000,
        description: 'Potong sesuai bentuk (Die Cut)',
      ),
    ];
  }
}
