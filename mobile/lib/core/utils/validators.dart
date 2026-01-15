class Validators {
  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  /// Validate password (minimum 6 characters)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    return null;
  }

  /// Validate required field
  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  /// Validate phone number (Indonesian format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.length < 10 || cleaned.length > 13) {
      return 'Nomor telepon tidak valid';
    }
    
    if (!cleaned.startsWith('08') && !cleaned.startsWith('62')) {
      return 'Nomor telepon harus diawali 08 atau 62';
    }
    
    return null;
  }

  /// Validate number (positive integer)
  static String? positiveNumber(String? value, [String fieldName = 'Nilai']) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName harus berupa angka';
    }
    
    if (number <= 0) {
      return '$fieldName harus lebih dari 0';
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? passwordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    
    if (value != password) {
      return 'Password tidak cocok';
    }
    
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    
    if (value.length < min) {
      return '$fieldName minimal $min karakter';
    }
    
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for max length
    }
    
    if (value.length > max) {
      return '$fieldName maksimal $max karakter';
    }
    
    return null;
  }
}
