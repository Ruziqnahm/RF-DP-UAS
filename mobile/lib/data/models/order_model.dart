import 'dart:convert';
import 'package:flutter/material.dart';

// Model `Order` menyimpan semua informasi terkait satu pemesanan.
// Digunakan untuk menampilkan riwayat pemesanan, detail order, dan
// komunikasi dengan API backend.
class Order {
  final int id;
  final int userId;
  final int productId;
  final String productName;
  final int materialId;
  final String materialName;
  final String size;
  final double? customWidth;
  final double? customHeight;
  final String finishing;
  final int quantity;
  final int totalPrice;
  // status alur kerja order: pending, processing, printing, completed, cancelled
  final String status;
  // status approval oleh admin: pending_review, approved, rejected
  final String approvalStatus;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final String? notes;
  // filePaths menyimpan lokasi file yang diunggah user (gambar/desain)
  final List<String> filePaths;
  final DateTime? deliveryDate;
  final bool isUrgent;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.materialId,
    required this.materialName,
    required this.size,
    this.customWidth,
    this.customHeight,
    required this.finishing,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    this.approvalStatus = 'pending_review',
    this.rejectionReason,
    this.reviewedAt,
    this.notes,
    required this.filePaths,
    this.deliveryDate,
    required this.isUrgent,
    required this.createdAt,
    required this.updatedAt,
  });

  // Konstruktor dari JSON. Perhatikan penanganan `file_paths` yang bisa
  // tiba sebagai string JSON atau sebagai array langsung.
  factory Order.fromJson(Map<String, dynamic> json) {
    List<String> parsedFilePaths = [];
    if (json['file_paths'] != null) {
      if (json['file_paths'] is String) {
        try {
          final decoded = json['file_paths'];
          if (decoded.startsWith('[')) {
            parsedFilePaths = List<String>.from(
              (jsonDecode(decoded) as List).map((e) => e.toString()),
            );
          } else {
            parsedFilePaths = [decoded];
          }
        } catch (e) {
          parsedFilePaths = [json['file_paths']];
        }
      } else if (json['file_paths'] is List) {
        parsedFilePaths = List<String>.from(json['file_paths']);
      }
    }

    // Handle product relationship
    String productName = '';
    if (json['product_name'] != null) {
      productName = json['product_name'];
    } else if (json['product'] != null) {
      final product = json['product'];
      if (product is Map) {
        productName = product['name'] ?? '';
      }
    }

    // Handle material relationship
    String materialName = '';
    int materialId = 0;
    if (json['material_name'] != null) {
      materialName = json['material_name'];
    } else if (json['material'] != null && json['material'] is Map) {
      materialName = json['material']['name'] ?? '';
      materialId = json['material']['id'] ?? 0;
    }
    if (json['material_id'] != null) {
      materialId = json['material_id'] as int;
    }

    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      productId: json['product_id'] as int,
      productName: productName,
      materialId: materialId,
      materialName: materialName,
      size: json['size'] ?? '',
      customWidth: json['width'] != null || json['custom_width'] != null
          ? double.tryParse((json['width'] ?? json['custom_width']).toString())
          : null,
      customHeight: json['height'] != null || json['custom_height'] != null
          ? double.tryParse((json['height'] ?? json['custom_height']).toString())
          : null,
      finishing: json['finishing'] ?? '',
      quantity: json['quantity'] is String 
          ? int.tryParse(json['quantity']) ?? 0 
          : (json['quantity'] as int? ?? 0),
      totalPrice: json['total_price'] is String
          ? (double.tryParse(json['total_price']) ?? 0).toInt()
          : (json['total_price'] is int 
              ? json['total_price'] as int
              : (json['total_price'] as num?)?.toInt() ?? 0),
      status: json['status'] ?? 'pending',
      approvalStatus: json['approval_status'] ?? 'pending_review',
      rejectionReason: json['rejection_reason'],
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'].toString())
          : null,
      notes: json['notes'] ?? json['admin_notes'],
      filePaths: parsedFilePaths,
      deliveryDate: json['delivery_date'] != null || json['deadline_date'] != null
          ? DateTime.tryParse((json['delivery_date'] ?? json['deadline_date']).toString())
          : null,
      isUrgent: json['is_urgent'] == 1 || json['is_urgent'] == true,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }

  // Konversi ke JSON untuk dikirim ke API jika diperlukan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'material_id': materialId,
      'material_name': materialName,
      'size': size,
      'custom_width': customWidth,
      'custom_height': customHeight,
      'finishing': finishing,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
      'notes': notes,
      'file_paths': filePaths,
      'delivery_date': deliveryDate?.toIso8601String(),
      'is_urgent': isUrgent ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper untuk format harga dengan pemisah ribuan (mis. 1.000.000)
  String getFormattedPrice() {
    return totalPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Helper untuk mendapatkan label status dalam Bahasa Indonesia
  String getStatusLabel() {
    final mappedStatus = _mapBackendStatus(status);
    switch (mappedStatus.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'processing':
        return 'Sedang Diproses';
      case 'printing':
        return 'Sedang Dicetak';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  // Map backend status ke UI status
  String _mapBackendStatus(String backendStatus) {
    switch (backendStatus.toLowerCase()) {
      case 'pending':
        return 'pending';
      case 'confirmed':
        return 'processing'; // confirmed maps to processing
      case 'processing':
        return 'processing';
      case 'ready':
        return 'printing'; // ready maps to printing
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return backendStatus;
    }
  }

  // Warna UI untuk status order
  Color getStatusColor() {
    final mappedStatus = _mapBackendStatus(status);
    switch (mappedStatus.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'printing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Label approval admin
  String getApprovalStatusLabel() {
    switch (approvalStatus.toLowerCase()) {
      case 'pending_review':
        return 'Menunggu Review Admin';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Unknown';
    }
  }

  // Warna untuk status approval
  Color getApprovalStatusColor() {
    switch (approvalStatus.toLowerCase()) {
      case 'pending_review':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Ikon visual untuk status approval
  IconData getApprovalStatusIcon() {
    switch (approvalStatus.toLowerCase()) {
      case 'pending_review':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Format ukuran jika custom
  String getFormattedSize() {
    if (size == 'Custom' && customWidth != null && customHeight != null) {
      return '${customWidth}x${customHeight} cm';
    }
    return size;
  }
}
