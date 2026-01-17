import 'dart:typed_data';

class FileMetadata {
  final String path;
  final int size;
  final Uint8List? webBytes; // For web preview

  FileMetadata({
    required this.path,
    required this.size,
    this.webBytes,
  });
}

class OrderSpecification {
  String? size;
  double? customWidth;
  double? customHeight;
  int? materialId;
  String? finishing;
  int quantity;
  String? notes;
  List<String> filePaths; // Multiple files (backward compatibility)
  List<FileMetadata> fileMetadataList; // New: with size and preview data
  DateTime? deliveryDate;
  bool isUrgent;

  OrderSpecification({
    this.size,
    this.customWidth,
    this.customHeight,
    this.materialId,
    this.finishing,
    this.quantity = 1,
    this.notes,
    List<String>? filePaths,
    List<FileMetadata>? fileMetadataList,
    this.deliveryDate,
    this.isUrgent = false,
  }) : filePaths = filePaths ?? [],
       fileMetadataList = fileMetadataList ?? [];

  // cek form udah lengkap belum
  bool isComplete() {
    if (size == null || materialId == null || finishing == null) {
      return false;
    }
    
    // kalau custom, harus ada width & height
    if (size == 'Custom' && (customWidth == null || customHeight == null)) {
      return false;
    }
    
    return true;
  }

  // hitung luas (m2)
  double getArea() {
    if (size == 'A3') {
      return 0.297 * 0.42;
    } else if (size == 'A4') {
      return 0.21 * 0.297;
    } else if (size == 'A5') {
      return 0.148 * 0.21;
    } else if (size == 'Custom' && customWidth != null && customHeight != null) {
      return (customWidth! / 100) * (customHeight! / 100); // cm ke m
    }
    
    return 0;
  }
}
