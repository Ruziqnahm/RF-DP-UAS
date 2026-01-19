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
      // Banner (ID 1)
      Finishing(
        id: 1,
        productId: 1,
        name: 'Tanpa Finishing',
        additionalPrice: 0,
        description: 'Potong pas gambar',
      ),
      Finishing(
        id: 2,
        productId: 1,
        name: 'Mata Ayam (Cincin)',
        additionalPrice: 0,
        description: 'Lubang ring di setiap sudut (Gratis)',
      ),
      Finishing(
        id: 3,
        productId: 1,
        name: 'Lipat Saja',
        additionalPrice: 0,
        description: 'Dilipat rapi tanpa ring',
      ),
      Finishing(
        id: 4,
        productId: 1,
        name: 'Selongsong',
        additionalPrice: 5000,
        description: 'Lebihan bahan untuk bambu/kayu',
      ),

      // Sticker (ID 2)
      Finishing(
        id: 5,
        productId: 2,
        name: 'Tanpa Finishing',
        additionalPrice: 0,
        description: 'Potong per lembar A3',
      ),
      Finishing(
        id: 6,
        productId: 2,
        name: 'Kiss Cut',
        additionalPrice: 5000,
        description: 'Potong bentuk (masih dalam lembaran)',
      ),
      Finishing(
        id: 7,
        productId: 2,
        name: 'Die Cut (Putus)',
        additionalPrice: 10000,
        description: 'Potong putus sesuai bentuk satuan',
      ),
      Finishing(
        id: 8,
        productId: 2,
        name: 'Laminating Glossy',
        additionalPrice: 5000,
        description: 'Lapisan mengkilap tahan gores',
      ),
      Finishing(
        id: 9,
        productId: 2,
        name: 'Laminating Doff',
        additionalPrice: 5000,
        description: 'Lapisan matte elegan',
      ),

      // Kartu Nama (ID 3)
      Finishing(
        id: 10,
        productId: 3,
        name: 'Tanpa Finishing',
        additionalPrice: 0,
        description: 'Potong kotak standar',
      ),
      Finishing(
        id: 11,
        productId: 3,
        name: 'Laminating Glossy 1 Sisi',
        additionalPrice: 15000,
        description: 'Per box',
      ),
      Finishing(
        id: 12,
        productId: 3,
        name: 'Laminating Doff 1 Sisi',
        additionalPrice: 15000,
        description: 'Per box',
      ),
      Finishing(
        id: 13,
        productId: 3,
        name: 'Rounded Corner',
        additionalPrice: 5000,
        description: 'Sudut melengkung',
      ),

      // UV Printing (ID 4)
      Finishing(
        id: 14,
        productId: 4,
        name: 'Tanpa Finishing',
        additionalPrice: 0,
        description: 'Cetak saja',
      ),
      Finishing(
        id: 15,
        productId: 4,
        name: 'Varnish Glossy',
        additionalPrice: 20000,
        description: 'Lapisan bening mengkilap',
      ),
      Finishing(
        id: 16,
        productId: 4,
        name: 'Emboss (Timbul)',
        additionalPrice: 30000,
        description: 'Cetak timbul 3D',
      ),
    ];
  }
}
