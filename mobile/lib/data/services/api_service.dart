import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/material_model.dart';
import '../models/finishing_model.dart';

// Service sederhana untuk berkomunikasi dengan backend Laravel.
// Semua method bersifat `static` agar mudah dipanggil dari UI/Provider.
class ApiService {
  // Ganti dengan IP address komputer Anda yang menjalankan Laravel
  // Untuk testing lokal: http://192.168.x.x:8000/api
  // Untuk production: https://yourdomain.com/api
  static const String baseUrl = 'http://localhost:8000/api';

  // Alternative untuk emulator Android
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Headers default untuk request JSON
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ============ PRODUCTS API ============

  /// Ambil semua produk beserta relasinya (materials, finishings)
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
      // Kembalikan data dummy sebagai fallback agar UI tetap tampil
      return Product.getDummyProducts();
    }
  }

  /// Ambil detail produk berdasarkan ID
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

  /// Ambil daftar material untuk sebuah produk
  static Future<List<Material>> getMaterialsForProduct(int productId) async {
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

  /// Ambil daftar finishing untuk sebuah produk
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

      // Debug: Print request body
      print('=== CREATE ORDER REQUEST ===');
      print('URL: $baseUrl/orders');
      print('Body: ${json.encode(body)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      // Debug: Print response
      print('=== CREATE ORDER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        print('✅ Order created successfully!');
        return {
          'success': true,
          'message': data['message'],
          'order': data['data'],
        };
      } else {
        print('❌ Failed to create order: ${data['message']}');
        // Include validation errors if available
        String errorMessage = data['message'] ?? 'Failed to create order';
        if (data['errors'] != null) {
          errorMessage += '\nErrors: ${json.encode(data['errors'])}';
        }
        return {
          'success': false,
          'message': errorMessage,
          'errors': data['errors'],
        };
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Ambil daftar order, bisa difilter dengan nomor telepon pelanggan
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

  /// Update status order
  static Future<bool> updateOrderStatus({
    required int orderId,
    required String status,
    String? adminNotes,
  }) async {
    try {
      final body = {
        'status': status,
        if (adminNotes != null) 'admin_notes': adminNotes,
      };

      final response = await http
          .patch(
            Uri.parse('$baseUrl/orders/$orderId/status'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Hitung perkiraan harga berdasarkan parameter yang diberikan
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

  /// Approve an order
  static Future<bool> approveOrder(int orderId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/$orderId/approve'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error approving order: $e');
      return false;
    }
  }

  /// Reject an order with a reason
  static Future<bool> rejectOrder(int orderId, String rejectionReason) async {
    try {
      final body = {
        'rejection_reason': rejectionReason,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/$orderId/reject'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error rejecting order: $e');
      return false;
    }
  }
}
