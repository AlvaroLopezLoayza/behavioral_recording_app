import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/intervention_remote_datasource.dart';
import '../models/intervention_plan_model.dart';
import '../../domain/entities/intervention_plan.dart';
import '../../domain/entities/phase_change.dart';
import '../../domain/repositories/intervention_repository.dart';

class InterventionRepositoryImpl implements InterventionRepository {
  final InterventionRemoteDataSource remoteDataSource;

  InterventionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<InterventionPlan>>> getPlansByHypothesis(String hypothesisId) async {
    try {
      final plans = await remoteDataSource.getPlansByHypothesis(hypothesisId);
      return Right(plans);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, InterventionPlan>> createPlan(InterventionPlan plan) async {
    try {
      final planModel = InterventionPlanModel.fromEntity(plan);
      final result = await remoteDataSource.createPlan(planModel);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, InterventionPlan>> updatePlan(InterventionPlan plan) async {
    try {
      final planModel = InterventionPlanModel.fromEntity(plan);
      final result = await remoteDataSource.updatePlan(planModel);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePlan(String planId) async {
    try {
      await remoteDataSource.deletePlan(planId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PhaseChange>>> getPhaseChanges(String behaviorId) async {
    try {
      final history = await remoteDataSource.getPhaseChanges(behaviorId);
      final changes = history.map((json) {
        return PhaseChange(
          date: DateTime.parse(json['changed_at']),
          newStatus: json['new_status'],
          planId: json['plan_id'],
        );
      }).toList();
      return Right(changes);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
