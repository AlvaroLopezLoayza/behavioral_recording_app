import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base class for all use cases in the application
/// T is the return type wrapped in Either<Failure, T>
/// Params is the input parameter type (use NoParams if none needed)
abstract class UseCase<T, Params> {
  /// Execute the use case with given parameters
  /// Returns Either<Failure, T> for explicit error handling
  Future<Either<Failure, T>> call(Params params);
}

/// Use this class when a use case doesn't require any parameters
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
