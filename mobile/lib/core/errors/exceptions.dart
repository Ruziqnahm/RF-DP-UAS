// Base Exception
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

// Network Exceptions
class NetworkException extends AppException {
  NetworkException(super.message);
}

class ServerException extends AppException {
  ServerException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class NotFoundException extends AppException {
  NotFoundException(super.message);
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException(super.message, {this.errors});
}

// Cache Exception
class CacheException extends AppException {
  CacheException(super.message);
}
