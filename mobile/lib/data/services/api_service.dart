import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/material_model.dart';
import '../models/finishing_model.dart';

class ApiService {
  // Ganti dengan IP address komputer Anda yang menjalankan Laravel
  // Untuk testing lokal: http://192.168.x.x:8000/api
  // Untuk production: https://yourdomain.com/api
  static const String baseUrl = 'http://192.168.1.100:8000/api';

  // Alternative untuk emulator Android
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ============ PRODUCTS API ============

  /// Fetch all products with materials and finishings
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/products'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List productsJson = data['data'];
          return productsJson.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      // Return dummy data as fallback
      return Product.getDummyProducts();
    }
  }

  /// Fetch single product by ID
  static Future<Product?> getProduct(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Product.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  /// Fetch materials for a specific product
  static Future<List<PrintMaterial>> getMaterialsForProduct(
      int productId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/$productId/materials'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List materialsJson = data['data'];
          return materialsJson
              .map((json) => PrintMaterial.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching materials: $e');
      return PrintMaterial.getDummyMaterials();
    }
  }

  /// Fetch finishings for a specific product
  static Future<List<Finishing>> getFinishingsForProduct(int productId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/$productId/finishings'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List finishingsJson = data['data'];
          return finishingsJson
              .map((json) => Finishing.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching finishings: $e');
      return [];
    }
  }

  // ============ ORDERS API ============

  /// Create a new order
  static Future<Map<String, dynamic>> createOrder({
    required int productId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    double? width,
    double? height,
    required int quantity,
    int? materialId,
    int? finishingId,
    required double subtotal,
    double? materialCost,
    double? finishingCost,
    required double totalPrice,
    bool isUrgent = false,
    String? deadlineDate,
    String? customerNotes,
    List<String>? filePaths,
  }) async {
    try {
      final body = {
        'product_id': productId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        if (customerEmail != null) 'customer_email': customerEmail,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'quantity': quantity,
        if (materialId != null) 'material_id': materialId,
        if (finishingId != null) 'finishing_id': finishingId,
        'subtotal': subtotal,
        'material_cost': materialCost ?? 0,
        'finishing_cost': finishingCost ?? 0,
        'total_price': totalPrice,
        'is_urgent': isUrgent,
        if (deadlineDate != null) 'deadline_date': deadlineDate,
        if (customerNotes != null) 'customer_notes': customerNotes,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'order': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      print('Error creating order: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Fetch orders (optionally filter by customer phone)
  static Future<List<Map<String, dynamic>>> getOrders(
      {String? customerPhone}) async {
    try {
      String url = '$baseUrl/orders';
      if (customerPhone != null) {
        url += '?customer_phone=$customerPhone';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  /// Calculate price
  static Future<Map<String, dynamic>?> calculatePrice({
    required int productId,
    double? width,
    double? height,
    required int quantity,
    int? materialId,
    int? finishingId,
    bool isUrgent = false,
  }) async {
    try {
      final body = {
        'product_id': productId,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'quantity': quantity,
        if (materialId != null) 'material_id': materialId,
        if (finishingId != null) 'finishing_id': finishingId,
        'is_urgent': isUrgent,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/calculate-price'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error calculating price: $e');
      return null;
    }
  }
}
