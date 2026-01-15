class AppConstants {
  // App Info
  static const String appName = 'RF Digital Printing';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplikasi Pemesanan Digital Printing';

  // Contact Info
  static const String whatsappNumber = '6281234567890';
  static const String email = 'rfdigitalprinting@gmail.com';
  static const String address = 'Jl. Contoh No. 123, Yogyakarta';
  static const String instagram = '@rfdigitalprinting';

  // Business Hours
  static const String businessHours = 'Senin - Sabtu: 08:00 - 17:00';
  static const String closedDays = 'Minggu & Hari Libur Nasional';

  // Order Status
  static const String orderPending = 'pending';
  static const String orderProcessing = 'processing';
  static const String orderCompleted = 'completed';
  static const String orderCancelled = 'cancelled';

  // Approval Status
  static const String approvalPending = 'pending';
  static const String approvalApproved = 'approved';
  static const String approvalRejected = 'rejected';

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedFileTypes = ['jpg', 'jpeg', 'png', 'pdf', 'ai', 'psd'];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 100;
  static const int maxNotesLength = 500;

  // Defaults
  static const int defaultQuantity = 1;
  static const int minQuantity = 1;
  static const int maxQuantity = 1000;

  // Images
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String logoImage = 'assets/logo/logo.png';
  static const String emptyStateImage = 'assets/images/empty_state.png';
}
