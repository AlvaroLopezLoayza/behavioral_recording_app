/// Base exception class for custom exceptions
/// Exceptions are thrown at the data layer and caught at the repository layer
class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when server/backend returns an error
class ServerException extends AppException {
  const ServerException([String message = 'Server error', String? code]) 
      : super(message, code);
}

/// Thrown when network connection is unavailable
class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection']) 
      : super(message);
}

/// Thrown when data validation fails
class ValidationException extends AppException {
  const ValidationException([String message = 'Validation failed']) 
      : super(message);
}

/// Thrown when requested data is not found
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Data not found']) 
      : super(message);
}

/// Thrown when authentication fails
class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed', String? code]) 
      : super(message, code);
}

/// Thrown when cache operations fail
class CacheException extends AppException {
  const CacheException([String message = 'Cache operation failed']) 
      : super(message);
}

/// Thrown for unexpected errors
class UnexpectedException extends AppException {
  const UnexpectedException([String message = 'Unexpected error occurred']) 
      : super(message);
}
