import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Failures represent errors that have been handled and converted from exceptions
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Server-side failures (from Supabase or API)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

/// Invalid input or business rule violation failures
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error']) : super(message);
}

/// Data not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Data not found']) : super(message);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication error']) : super(message);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error']) : super(message);
}

/// Unexpected/unknown failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'An unexpected error occurred']) : super(message);
}
