import 'material_model.dart';
import 'finishing_model.dart';

// Model `Product` merepresentasikan data produk yang didapat dari API
// atau digunakan secara lokal (dummy). Semua field dibuat immutable
// (final) agar model tetap sederhana dan mudah dipakai di UI.
class Product {
  // Identitas produk dari backend
  final int id;
  // Nama produk (mis. Banner Indoor)
  final String name;
  // Kategori produk (mis. Banner, Stiker)
  final String category;
  // Harga dasar dalam satuan integer (mis. Rupiah)
  final int basePrice;
  // Satuan (Meter, Lembar, Pack)
  final String unit;
  // Deskripsi singkat produk
  final String description;
  // Path atau URL gambar produk
  final String imageUrl;
  // Status aktif produk
  final bool isActive;
  // Relasi satu-ke-banyak: bahan yang tersedia untuk produk ini
  final List<Material>? materials;
  // Relasi satu-ke-banyak: opsi finishing untuk produk ini
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

  // Membuat instance `Product` dari JSON (payload API Laravel)
  // Catatan: beberapa API mengembalikan angka sebagai String, sehingga
  // parsing aman dilakukan dengan pengecekan tipe.
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

  // Mengubah model menjadi Map untuk dikirimkan ke API jika diperlukan
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

  // Contoh data dummy lokal untuk presentasi atau fallback
  static List<Product> getDummyProducts() {
    return [
      Product(
        id: 1,
        name: 'Banner ',
        category: 'Banner',
        basePrice: 20000,
        unit: 'Meter',
        description: 'Banner dengan kualitas printing terbaik - Rp 20.000/Meter',
        imageUrl: 'assets/images/cetak_banner.jpg',
      ),
      Product(
        id: 2,
        name: 'Stiker Vinyl',
        category: 'Stiker',
        basePrice: 10000,
        unit: 'Lembar',
        description: 'Stiker vinyl (32x48 cm).',
        imageUrl: 'assets/images/cetak_stiker_vinyl.jpg',
      ),
      Product(
        id: 3,
        name: 'Kartu Nama',
        category: 'Kartu',
        basePrice: 30000,
        unit: 'Pack',
        description: 'Kartu nama dengan bahan premium - Rp 30.000/pack',
        imageUrl: 'assets/images/kartu_nama.jpg',
      ),
      Product(
        id: 4,
        name: 'UV Printing (Flatbed)',
        category: 'UV',
        basePrice: 15000,
        unit: 'Pack',
        description: 'Cetak UV dengan hasil timbul dan glossy - Rp 15.000/pack',
        imageUrl: 'assets/images/uv_cetak.jpg',
      ),
    ];
  }
}
