import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/models/material_model.dart';
import '../../data/models/finishing_model.dart';
import '../../data/services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch products dari API atau fallback ke dummy data
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch from API
      _products = await ApiService.getProducts();
      print('✓ Products loaded from API: ${_products.length} items');
    } catch (e) {
      _error = 'Gagal memuat produk dari server, menggunakan data lokal';
      print('Fetch products error: $e');

      // Fallback ke dummy data
      _products = Product.getDummyProducts();
      print('✓ Using local dummy data: ${_products.length} items');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch materials for a specific product
  Future<List<PrintMaterial>> getMaterialsForProduct(int productId) async {
    try {
      final materials = await ApiService.getMaterialsForProduct(productId);
      print(
          '✓ Materials loaded for product $productId: ${materials.length} items');
      return materials;
    } catch (e) {
      print('Error fetching materials: $e');
      return PrintMaterial.getDummyMaterials();
    }
  }

  // Fetch finishings for a specific product
  Future<List<Finishing>> getFinishingsForProduct(int productId) async {
    try {
      final finishings = await ApiService.getFinishingsForProduct(productId);
      print(
          '✓ Finishings loaded for product $productId: ${finishings.length} items');
      return finishings;
    } catch (e) {
      print('Error fetching finishings: $e');
      return [];
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Get product by id
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
