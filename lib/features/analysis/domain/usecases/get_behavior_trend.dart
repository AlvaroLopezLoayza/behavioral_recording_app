import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../abc_recording/domain/entities/abc_record.dart';
import '../../../abc_recording/domain/repositories/abc_recording_repository.dart';
import '../entities/trend_analysis.dart';
import '../../../intervention/domain/repositories/intervention_repository.dart';
import '../../../intervention/domain/entities/phase_change.dart';

class GetBehaviorTrendParams {
  final String behaviorDefinitionId;
  final int days; // Number of days to look back

  const GetBehaviorTrendParams({
    required this.behaviorDefinitionId,
    this.days = 7,
  });
}

class GetBehaviorTrend implements UseCase<TrendAnalysis, GetBehaviorTrendParams> {
  final AbcRecordingRepository repository;
  final InterventionRepository interventionRepository;

  GetBehaviorTrend(this.repository, this.interventionRepository);

  @override
  Future<Either<Failure, TrendAnalysis>> call(GetBehaviorTrendParams params) async {
    final recordsResult = await repository.getRecordsByBehavior(params.behaviorDefinitionId);
    final phaseChangesResult = await interventionRepository.getPhaseChanges(params.behaviorDefinitionId);
    
    // Default empty list for phase changes if error (non-critical for trend)
    final phaseChanges = phaseChangesResult.getOrElse(() => []);

    return recordsResult.fold(
      (failure) => Left(failure),
      (records) {
        // ... (rest of the logic)
        
        // Group by date
        final frequencyMap = <DateTime, int>{};
        
        // Filter records by date range
        final cutoffDate = DateTime.now().subtract(Duration(days: params.days));
        final filteredRecords = records.where((r) => r.timestamp.isAfter(cutoffDate)).toList();
        
        // Initialize all days with 0 to show gaps
        for (int i = 0; i < params.days; i++) {
          final day = DateTime.now().subtract(Duration(days: i));
          final dateKey = DateTime(day.year, day.month, day.day);
          frequencyMap[dateKey] = 0;
        }
        
        // Count occurrences
        for (final record in filteredRecords) {
          final date = record.timestamp;
          final dateKey = DateTime(date.year, date.month, date.day);
          if (frequencyMap.containsKey(dateKey)) {
            frequencyMap[dateKey] = (frequencyMap[dateKey] ?? 0) + 1;
          }
        }
        
        // Convert to list and sort
        final dataPoints = frequencyMap.entries
            .map((e) => DailyFrequency(date: e.key, count: e.value))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
          
        // Calculate stats
        final counts = dataPoints.isEmpty ? <int>[] : dataPoints.map((e) => e.count).toList();
        final max = counts.isEmpty ? 0 : counts.fold(0, (prev, curr) => curr > prev ? curr : prev);
        final avg = counts.isEmpty ? 0.0 : counts.reduce((a, b) => a + b) / dataPoints.length;
        
        return Right(TrendAnalysis(
          behaviorId: params.behaviorDefinitionId,
          dataPoints: dataPoints,
          phaseChanges: phaseChanges,
          averageFrequency: avg,
          maxFrequency: max,
        ));
      },
    );
  }
}
