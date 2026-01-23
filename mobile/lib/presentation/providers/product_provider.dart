import 'package:flutter/material.dart' hide Material;
import '../../data/models/product_model.dart';
import '../../data/models/material_model.dart';
import '../../data/models/finishing_model.dart';
import '../../data/services/api_service.dart';

// Provider untuk mengelola state produk di aplikasi.
// Bertanggung jawab untuk memuat data dari API (atau fallback lokal)
// lalu memberi tahu UI ketika data berubah melalui ChangeNotifier.
class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Memuat daftar produk dari API. Jika gagal, menggunakan dummy data.
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ApiService.getProducts();
      print('✓ Products loaded from API: ${_products.length} items');
    } catch (e) {
      _error = 'Gagal memuat produk dari server, menggunakan data lokal';
      print('Fetch products error: $e');
      _products = Product.getDummyProducts();
      print('✓ Using local dummy data: ${_products.length} items');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mengambil material untuk produk tertentu (dipanggil saat membuka detail)
  Future<List<Material>> getMaterialsForProduct(int productId) async {
    try {
      final materials = await ApiService.getMaterialsForProduct(productId);
      print('✓ Materials loaded for product $productId: ${materials.length} items');
      return materials;
    } catch (e) {
      print('Error fetching materials: $e');
      return Material.getDummyMaterials();
    }
  }

  // Mengambil opsi finishing untuk produk tertentu
  Future<List<Finishing>> getFinishingsForProduct(int productId) async {
    try {
      final finishings = await ApiService.getFinishingsForProduct(productId);
      print('✓ Finishings loaded for product $productId: ${finishings.length} items');
      return finishings;
    } catch (e) {
      print('Error fetching finishings: $e');
      return [];
    }
  }

  // Mengambil produk berdasarkan kategori (untuk tampilan kategori)
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Mengambil produk berdasarkan ID (digunakan di halaman detail)
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
