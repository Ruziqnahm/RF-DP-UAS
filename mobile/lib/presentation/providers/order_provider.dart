import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';
import '../../data/models/product_model.dart';
import '../../data/models/material_model.dart' as mat;
import '../../data/models/specification_model.dart';
import '../../data/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  Product? _selectedProduct;
  OrderSpecification _specification = OrderSpecification();
  int _totalPrice = 0;
  
  // Order history
  List<Order> _orders = [];
  bool _isLoadingOrders = false;
  String? _errorMessage;
  
  // getter
  Product? get selectedProduct => _selectedProduct;
  OrderSpecification get specification => _specification;
  int get totalPrice => _totalPrice;
  List<Order> get orders => _orders;
  bool get isLoadingOrders => _isLoadingOrders;
  String? get errorMessage => _errorMessage;
  
  // Price breakdown getters
  int get baseProductPrice {
    if (_selectedProduct == null) return 0;
    return _selectedProduct!.basePrice;
  }
  
  int get materialCost {
    if (!_specification.isComplete() || _selectedProduct == null) return 0;
    
    // Untuk Banner: hitung berdasarkan meter
    if (_selectedProduct!.name.toLowerCase().contains('banner')) {
      double area = _specification.getArea();
      return (_selectedProduct!.basePrice * area).round();
    }
    
    // Untuk produk lain: harga base per unit
    return _selectedProduct!.basePrice;
  }
  
  int get finishingCost {
    // Tidak ada biaya finishing terpisah karena sudah include di harga
    return 0;
  }
  
  int get subtotal {
    if (!_specification.isComplete() || _selectedProduct == null) return 0;
    
    int pricePerUnit = materialCost;
    return pricePerUnit * _specification.quantity;
  }
  
  int get urgentFee {
    if (!_specification.isUrgent) return 0;
    return (subtotal * 0.3).round();
  }
  
  // Estimasi waktu pengerjaan (dalam hari)
  int get estimatedDays {
    if (_selectedProduct == null || !_specification.isComplete()) return 0;
    
    // Base time berdasarkan produk
    int baseDays = 3; // default 3 hari
    
    if (_selectedProduct!.name.toLowerCase().contains('banner')) {
      baseDays = 2;
    } else if (_selectedProduct!.name.toLowerCase().contains('sticker')) {
      baseDays = 1;
    } else if (_selectedProduct!.name.toLowerCase().contains('kartu')) {
      baseDays = 2;
    } else if (_selectedProduct!.name.toLowerCase().contains('uv')) {
      baseDays = 3;
    }
    
    // Tambah waktu jika quantity banyak
    if (_specification.quantity > 100) {
      baseDays += 1;
    }
    if (_specification.quantity > 500) {
      baseDays += 2;
    }
    
    // Tambah waktu jika ada laminating
    if (_specification.finishing == 'Laminating') {
      baseDays += 1;
    }
    
    // Jika urgent, waktu dikurangi
    if (_specification.isUrgent) {
      baseDays = (baseDays / 2).ceil();
      if (baseDays < 1) baseDays = 1;
    }
    
    return baseDays;
  }
  
  DateTime? get estimatedDeliveryDate {
    if (estimatedDays == 0) return null;
    return DateTime.now().add(Duration(days: estimatedDays));
  }

  // set produk
  void setProduct(Product product) {
    _selectedProduct = product;
    _specification = OrderSpecification();
    _totalPrice = 0;
    notifyListeners();
  }

  // update ukuran
  void setSize(String size) {
    _specification.size = size;
    
    if (size != 'Custom') {
      _specification.customWidth = null;
      _specification.customHeight = null;
    }
    
    calculatePrice();
    notifyListeners();
  }

  // custom size
  void setCustomSize(double? width, double? height) {
    _specification.customWidth = width;
    _specification.customHeight = height;
    calculatePrice();
    notifyListeners();
  }

  void setMaterial(int materialId) {
    _specification.materialId = materialId;
    calculatePrice();
    notifyListeners();
  }

  void setFinishing(String finishing) {
    _specification.finishing = finishing;
    calculatePrice();
    notifyListeners();
  }

  void setQuantity(int qty) {
    _specification.quantity = qty;
    calculatePrice();
    notifyListeners();
  }

  void setNotes(String notes) {
    _specification.notes = notes;
    notifyListeners();
  }

  // Validate file before adding
  String? validateFile(String filePath, int fileSize) {
    // Check file extension
    final fileName = filePath.split('/').last.split('\\').last;
    final extension = fileName.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    
    if (!allowedExtensions.contains(extension)) {
      return 'Hanya file JPG, PNG, dan PDF yang diperbolehkan';
    }
    
    // Check file size (max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    if (fileSize > maxSize) {
      return 'Ukuran file maksimal 5 MB';
    }
    
    // Check MIME type for extra validation
    final mimeType = lookupMimeType(fileName);
    if (mimeType == null || 
        (!mimeType.startsWith('image/') && mimeType != 'application/pdf')) {
      return 'Tipe file tidak valid';
    }
    
    return null; // Valid
  }

  // Add file with metadata
  Future<String?> addFile(String path, {Uint8List? webBytes}) async {
    // Max 3 files
    if (_specification.fileMetadataList.length >= 3) {
      return 'Maksimal 3 file';
    }
    
    int fileSize = 0;
    
    // Get file size
    if (kIsWeb && webBytes != null) {
      fileSize = webBytes.length;
    } else if (!kIsWeb) {
      try {
        final file = File(path);
        fileSize = await file.length();
      } catch (e) {
        return 'Gagal membaca file';
      }
    }
    
    // Validate file
    final validationError = validateFile(path, fileSize);
    if (validationError != null) {
      return validationError;
    }
    
    // Add to metadata list
    final metadata = FileMetadata(
      path: path,
      size: fileSize,
      webBytes: webBytes,
    );
    
    _specification.fileMetadataList.add(metadata);
    
    // Also add to filePaths for backward compatibility
    _specification.filePaths.add(path);
    
    notifyListeners();
    return null; // Success
  }

  void removeFile(int index) {
    if (index < _specification.fileMetadataList.length) {
      _specification.fileMetadataList.removeAt(index);
    }
    if (index < _specification.filePaths.length) {
      _specification.filePaths.removeAt(index);
    }
    notifyListeners();
  }
  
  // Legacy method for backward compatibility
  void setFilePath(String? path) {
    if (path == null) {
      _specification.filePaths = [];
      _specification.fileMetadataList = [];
    }
    notifyListeners();
  }

  void setDeliveryDate(DateTime date) {
    _specification.deliveryDate = date;
    notifyListeners();
  }

  void setUrgent(bool isUrgent) {
    _specification.isUrgent = isUrgent;
    calculatePrice();
    notifyListeners();
  }

  // hitung harga otomatis
  void calculatePrice() {
    if (_selectedProduct == null || !_specification.isComplete()) {
      _totalPrice = 0;
      return;
    }

    int subtotal = 0;
    final productName = _selectedProduct!.name.toLowerCase();

    if (productName.contains('banner')) {
      // Banner: Rp 20.000/Meter (dihitung dari luas dalam meter persegi)
      double area = _specification.getArea(); // dalam m²
      subtotal = (_selectedProduct!.basePrice * area * _specification.quantity).round();
    } else if (productName.contains('stiker vinyl')) {
      // Stiker Vinyl: harga berdasarkan ukuran
      String size = _specification.size ?? '';
      int base = _selectedProduct!.basePrice;
      if (size == 'A4') {
        subtotal = base * _specification.quantity;
      } else if (size == 'A3') {
        subtotal = (base * 2) * _specification.quantity; // A3 = 2x A4
      } else if (size == 'A5') {
        subtotal = (base ~/ 2) * _specification.quantity; // A5 = 1/2 A4
      } else if (size == 'Custom') {
        // Custom: hitung per m² (asumsi input customWidth & customHeight dalam cm, konversi ke m)
        double width = (_specification.customWidth ?? 0) / 100;
        double height = (_specification.customHeight ?? 0) / 100;
        double area = width * height;
        subtotal = (base * area * _specification.quantity).round();
      } else {
        subtotal = base * _specification.quantity;
      }
    } else if (productName.contains('kartu')) {
      // Kartu Nama: Rp 30.000/pack
      subtotal = _selectedProduct!.basePrice * _specification.quantity;
    } else if (productName.contains('uv')) {
      // UV Printing: Rp 15.000/pack
      subtotal = _selectedProduct!.basePrice * _specification.quantity;
    } else {
      // Default: harga base x quantity
      subtotal = _selectedProduct!.basePrice * _specification.quantity;
    }

    _totalPrice = subtotal;
    notifyListeners();
  }

  // generate pesan WA
  String generateWhatsAppMessage() {
    if (_selectedProduct == null) return '';

    String message = '''
Halo Admin RF Digital Printing,

Saya ingin memesan:

📦 *Produk:* ${_selectedProduct!.name}
📏 *Ukuran:* ${_getFormattedSize()}
🎨 *Bahan:* ${_getFormattedMaterial()}
✨ *Finishing:* ${_specification.finishing}
🔢 *Jumlah:* ${_specification.quantity} pcs
📁 *File Design:* ${_specification.filePaths.length} file(s)
''';

    if (_specification.deliveryDate != null) {
      message += '📅 *Tanggal Selesai:* ${_formatDate(_specification.deliveryDate!)}\n';
    }

    if (_specification.isUrgent) {
      message += '⚡ *URGENT* (+30% biaya)\n';
    }

    message += '\n💰 *Total Harga:* Rp ${_formatPrice(_totalPrice)}';

    if (_specification.notes != null && _specification.notes!.isNotEmpty) {
      message += '\n\n📝 *Catatan:* ${_specification.notes}';
    }

    message += '\n\nMohon konfirmasi ketersediaan. Terima kasih!';

    return message;
  }

  String _getFormattedSize() {
    if (_specification.size == 'Custom') {
      return '${_specification.customWidth} x ${_specification.customHeight} cm';
    }
    return _specification.size ?? '-';
  }

  String _getFormattedMaterial() {
    if (_specification.materialId == null) return '-';
    
    final materials = mat.Material.getDummyMaterials();
    final material = materials.firstWhere(
      (m) => m.id == _specification.materialId,
      orElse: () => materials[0],
    );
    
    return material.name;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Update order status (untuk demo - tidak perlu auth)
  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      // Untuk demo, langsung update local order list
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final oldOrder = _orders[index];
        _orders[index] = Order(
          id: oldOrder.id,
          userId: oldOrder.userId,
          productId: oldOrder.productId,
          productName: oldOrder.productName,
          materialId: oldOrder.materialId,
          materialName: oldOrder.materialName,
          size: oldOrder.size,
          customWidth: oldOrder.customWidth,
          customHeight: oldOrder.customHeight,
          finishing: oldOrder.finishing,
          quantity: oldOrder.quantity,
          totalPrice: oldOrder.totalPrice,
          status: newStatus,
          approvalStatus: oldOrder.approvalStatus,
          rejectionReason: oldOrder.rejectionReason,
          reviewedAt: oldOrder.reviewedAt,
          notes: oldOrder.notes,
          filePaths: oldOrder.filePaths,
          deliveryDate: oldOrder.deliveryDate,
          isUrgent: oldOrder.isUrgent,
          createdAt: oldOrder.createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Fetch orders (untuk demo - tidak perlu auth)
  Future<void> fetchOrders() async {
    _isLoadingOrders = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Untuk demo, gunakan dummy data atau data lokal
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Dummy orders untuk demo
      _orders = [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _orders = [];
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  // Create new order (untuk demo - tidak perlu auth)
  Future<bool> createOrder({
    required int productId,
    required int materialId,
  }) async {
    try {
      // Untuk demo, simpan ke local state saja
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Buat order dummy untuk demo
      final newOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 1,
        productId: productId,
        productName: _selectedProduct?.name ?? 'Product',
        materialId: materialId,
        materialName: 'Material Demo',
        size: _specification.size ?? 'A4',
        customWidth: _specification.customWidth,
        customHeight: _specification.customHeight,
        finishing: _specification.finishing ?? 'Tanpa Finishing',
        quantity: _specification.quantity,
        totalPrice: _totalPrice,
        status: 'pending',
        approvalStatus: 'pending_review',
        notes: _specification.notes,
        filePaths: _specification.filePaths,
        deliveryDate: _specification.deliveryDate,
        isUrgent: _specification.isUrgent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _orders.insert(0, newOrder);
      
      // Reset specification after successful order
      _specification = OrderSpecification();
      _totalPrice = 0;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }
  
  // Approve order (untuk demo - tidak perlu auth)
  Future<bool> approveOrder(int orderId) async {
    try {
      return await updateOrderStatus(orderId, 'approved');
    } catch (e) {
      print('Error approving order: $e');
      return false;
    }
  }
  
  // Reject order (untuk demo - tidak perlu auth)
  Future<bool> rejectOrder(int orderId, String reason) async {
    try {
      return await updateOrderStatus(orderId, 'rejected');
    } catch (e) {
      print('Error rejecting order: $e');
      return false;
    }
  }

  void reset() {
    _selectedProduct = null;
    _specification = OrderSpecification();
    _totalPrice = 0;
    notifyListeners();
  }
}
