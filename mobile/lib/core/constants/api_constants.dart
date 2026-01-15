class ApiConstants {
  // Base URL - ganti sesuai IP komputer Anda jika testing di device
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Untuk Android Emulator gunakan:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Untuk device real, gunakan IP komputer Anda:
  // static const String baseUrl = 'http://192.168.x.x:8000/api';
  
  // Auth Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String profile = '/profile';
  
  // Products & Materials Endpoints
  static const String products = '/products';
  static String productDetail(int id) => '/products/$id';
  static const String materials = '/materials';
  static String materialDetail(int id) => '/materials/$id';
  
  // Orders Endpoints
  static const String orders = '/orders';
  static String orderDetail(int id) => '/orders/$id';
  static String updateOrderStatus(int id) => '/orders/$id/status';
  static String approveOrder(int id) => '/orders/$id/approve';
  static String rejectOrder(int id) => '/orders/$id/reject';
  
  // Upload Endpoints
  static const String uploadDesign = '/upload-design';
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}
