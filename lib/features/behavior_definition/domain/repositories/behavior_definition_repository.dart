import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/behavior_definition.dart';

/// Repository interface for Behavior Definition operations
/// This defines the contract that the data layer must implement
abstract class BehaviorDefinitionRepository {
  /// Create a new behavior definition
  /// Returns Either<Failure, BehaviorDefinition> for explicit error handling
  Future<Either<Failure, BehaviorDefinition>> createDefinition(
    BehaviorDefinition definition,
  );

  /// Retrieve all behavior definitions for the current user
  Future<Either<Failure, List<BehaviorDefinition>>> getAllDefinitions({String? patientId});

  /// Get a specific behavior definition by ID
  Future<Either<Failure, BehaviorDefinition>> getDefinitionById(String id);

  /// Update an existing behavior definition
  Future<Either<Failure, BehaviorDefinition>> updateDefinition(
    BehaviorDefinition definition,
  );

  /// Delete a behavior definition
  Future<Either<Failure, void>> deleteDefinition(String id);

  /// Validate if an operational definition meets ABA criteria
  /// This ensures definitions are observable and measurable
  Future<Either<Failure, bool>> validateDefinition(
    String operationalDefinition,
  );
}
