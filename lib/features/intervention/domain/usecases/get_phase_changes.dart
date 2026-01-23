import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../analysis/domain/entities/trend_analysis.dart';
import '../entities/phase_change.dart';
import '../repositories/intervention_repository.dart';

class GetPhaseChanges {
  final InterventionRepository repository;

  GetPhaseChanges(this.repository);

  Future<Either<Failure, List<PhaseChange>>> call(String behaviorId) async {
    return await repository.getPhaseChanges(behaviorId);
  }
}
