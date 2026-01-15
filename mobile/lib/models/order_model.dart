import 'dart:convert';
import 'package:flutter/material.dart';

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
  final String status; // pending, processing, printing, completed, cancelled
  final String approvalStatus; // pending_review, approved, rejected
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final String? notes;
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

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse file_paths from JSON string or array
    List<String> parsedFilePaths = [];
    if (json['file_paths'] != null) {
      if (json['file_paths'] is String) {
        // If stored as JSON string, parse it
        try {
          final decoded = json['file_paths'];
          if (decoded.startsWith('[')) {
            // It's a JSON array string
            parsedFilePaths = List<String>.from(
              (jsonDecode(decoded) as List).map((e) => e.toString())
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

    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] ?? '',
      materialId: json['material_id'] as int,
      materialName: json['material_name'] ?? '',
      size: json['size'] ?? '',
      customWidth: json['custom_width'] != null 
          ? double.tryParse(json['custom_width'].toString()) 
          : null,
      customHeight: json['custom_height'] != null
          ? double.tryParse(json['custom_height'].toString())
          : null,
      finishing: json['finishing'] ?? '',
      quantity: json['quantity'] as int,
      totalPrice: json['total_price'] as int,
      status: json['status'] ?? 'pending',
      approvalStatus: json['approval_status'] ?? 'pending_review',
      rejectionReason: json['rejection_reason'],
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'])
          : null,
      notes: json['notes'],
      filePaths: parsedFilePaths,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.tryParse(json['delivery_date'])
          : null,
      isUrgent: json['is_urgent'] == 1 || json['is_urgent'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

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

  String getFormattedPrice() {
    return totalPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String getStatusLabel() {
    switch (status.toLowerCase()) {
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
  
  Color getStatusColor() {
    switch (status.toLowerCase()) {
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

  String getFormattedSize() {
    if (size == 'Custom' && customWidth != null && customHeight != null) {
      return '${customWidth}x${customHeight} cm';
    }
    return size;
  }
}
