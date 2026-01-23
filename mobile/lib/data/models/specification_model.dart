import 'dart:typed_data';

// Metadata untuk setiap file yang diupload, berguna untuk preview dan
// mengetahui ukuran file tanpa harus membaca isi file di tempat lain.
class FileMetadata {
  final String path;
  final int size;
  final Uint8List? webBytes; // Untuk preview di web/Flutter web

  FileMetadata({
    required this.path,
    required this.size,
    this.webBytes,
  });
}

// OrderSpecification menampung konfigurasi pesanan sebelum dikonversi
// menjadi objek `Order`. Ini menyimpan ukuran, material, finishing,
// file yang diupload, dan informasi pengiriman.
class OrderSpecification {
  String? size;
  double? customWidth;
  double? customHeight;
  int? materialId;
  String? finishing;
  int quantity;
  String? notes;
  // list path file (compatibility dengan implementasi lama)
  List<String> filePaths;
  // list metadata file yang lebih kaya (size + preview)
  List<FileMetadata> fileMetadataList;
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
  })  : filePaths = filePaths ?? [],
       fileMetadataList = fileMetadataList ?? [];

  // Validasi apakah spesifikasi sudah lengkap untuk melakukan order
  bool isComplete() {
    if (size == null || materialId == null || finishing == null) {
      return false;
    }

    // Jika ukuran custom, lebar dan tinggi harus diisi
    if (size == 'Custom' && (customWidth == null || customHeight == null)) {
      return false;
    }

    return true;
  }

  // Menghitung luas dalam meter persegi berdasarkan ukuran
  double getArea() {
    if (size == 'A3') {
      return 0.297 * 0.42;
    } else if (size == 'A4') {
      return 0.21 * 0.297;
    } else if (size == 'A5') {
      return 0.148 * 0.21;
    } else if (size == 'Custom' && customWidth != null && customHeight != null) {
      return (customWidth! / 100) * (customHeight! / 100); // cm -> m
    }

    return 0;
  }
}
