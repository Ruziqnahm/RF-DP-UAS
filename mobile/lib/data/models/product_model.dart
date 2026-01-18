import 'material_model.dart';
import 'finishing_model.dart';

class Product {
  final int id;
  final String name;
  final String category;
  final int basePrice;
  final String unit;
  final String description;
  final String imageUrl;
  final bool isActive;
  final List<PrintMaterial>? materials;
  final List<Finishing>? finishings;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    required this.unit,
    required this.description,
    required this.imageUrl,
    this.isActive = true,
    this.materials,
    this.finishings,
  });

  // From JSON (dari API Laravel)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      basePrice: (json['base_price'] is String)
          ? int.tryParse(json['base_price']) ?? 0
          : (json['base_price'] ?? 0).toInt(),
      unit: json['unit'] ?? 'Pack',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? 'assets/images/placeholder.jpg',
      isActive: json['is_active'] ?? true,
      materials: json['materials'] != null
          ? (json['materials'] as List)
              .map((m) => PrintMaterial.fromJson(m))
              .toList()
          : null,
      finishings: json['finishings'] != null
          ? (json['finishings'] as List)
              .map((f) => Finishing.fromJson(f))
              .toList()
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'base_price': basePrice,
      'unit': unit,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      if (materials != null)
        'materials': materials!.map((m) => m.toJson()).toList(),
      if (finishings != null)
        'finishings': finishings!.map((f) => f.toJson()).toList(),
    };
  }

  // dummy data produk (fallback jika API tidak tersedia)
  static List<Product> getDummyProducts() {
    return [
      Product(
        id: 1,
        name: 'Banner Indoor (Flexi)',
        category: 'Banner',
        basePrice: 20000,
        unit: 'Meter',
        description:
            'Banner indoor kualitas high-res. Harga dasar bahan standard.',
        imageUrl: 'assets/images/cetak_banner.jpg',
      ),
      Product(
        id: 2,
        name: 'Stiker Vinyl A3+',
        category: 'Stiker',
        basePrice: 15000,
        unit: 'Lembar',
        description: 'Stiker vinyl anti air ukuran A3+ (32x48 cm).',
        imageUrl: 'assets/images/cetak_stiker_vinyl.jpg',
      ),
      Product(
        id: 3,
        name: 'Kartu Nama',
        category: 'Kartu',
        basePrice: 40000,
        unit: 'Box',
        description: 'Kartu nama 1 muka, isi 100 pcs per box.',
        imageUrl: 'assets/images/kartu_nama.jpg',
      ),
      Product(
        id: 4,
        name: 'UV Printing (Flatbed)',
        category: 'UV',
        basePrice: 50000,
        unit: 'A4',
        description: 'Cetak UV timbul di media keras (Akrilik/Kayu/Case).',
        imageUrl: 'assets/images/uv_cetak.jpg',
      ),
    ];
  }
}
