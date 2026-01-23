import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/intervention_plan.dart';
import '../entities/phase_change.dart';

abstract class InterventionRepository {
  Future<Either<Failure, List<InterventionPlan>>> getPlansByHypothesis(String hypothesisId);
  Future<Either<Failure, InterventionPlan>> createPlan(InterventionPlan plan);
  Future<Either<Failure, InterventionPlan>> updatePlan(InterventionPlan plan);
  Future<Either<Failure, void>> deletePlan(String planId);
  Future<Either<Failure, List<PhaseChange>>> getPhaseChanges(String behaviorId);
}
