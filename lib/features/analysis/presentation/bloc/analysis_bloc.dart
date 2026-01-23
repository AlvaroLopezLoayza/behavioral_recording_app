import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_behavior_trend.dart';
import '../../domain/usecases/get_conditional_probabilities.dart';
import '../../../intervention/domain/usecases/get_phase_changes.dart';
import '../bloc/analysis_event.dart';
import '../bloc/analysis_state.dart';
import '../../domain/entities/trend_analysis.dart';
import '../../domain/entities/conditional_probability.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final GetBehaviorTrend getBehaviorTrend;
  final GetConditionalProbabilities getConditionalProbabilities;
  final GetPhaseChanges getPhaseChanges;

  AnalysisBloc({
    required this.getBehaviorTrend,
    required this.getConditionalProbabilities,
    required this.getPhaseChanges,
  }) : super(AnalysisInitial()) {
    on<LoadTrendAnalysis>(_onLoadTrendAnalysis);
    on<LoadConditionalProbabilities>(_onLoadConditionalProbabilities);
  }

  Future<void> _onLoadTrendAnalysis(
    LoadTrendAnalysis event,
    Emitter<AnalysisState> emit,
  ) async {
    final currentState = state;
    TrendAnalysis? existingTrendData;
    ConditionalProbabilityResult? existingProbabilityData;

    if (currentState is AnalysisLoaded) {
      existingTrendData = currentState.trendData;
      existingProbabilityData = currentState.probabilityData;
    } else if (currentState is AnalysisLoading) {
      existingTrendData = currentState.previousTrendData;
      existingProbabilityData = currentState.previousProbabilityData;
    }
    
    emit(AnalysisLoading(
      previousTrendData: existingTrendData,
      previousProbabilityData: existingProbabilityData,
    ));

    final trendResult = await getBehaviorTrend(
      GetBehaviorTrendParams(behaviorDefinitionId: event.behaviorDefinitionId),
    );
    final phaseResult = await getPhaseChanges(event.behaviorDefinitionId);

    trendResult.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (trendData) {
        final mergedTrendData = TrendAnalysis(
          behaviorId: trendData.behaviorId,
          dataPoints: trendData.dataPoints,
          phaseChanges: phaseResult.getOrElse(() => []),
          averageFrequency: trendData.averageFrequency,
          maxFrequency: trendData.maxFrequency,
        );
        emit(AnalysisLoaded(
          trendData: mergedTrendData, 
          probabilityData: existingProbabilityData
        ));
      },
    );
  }

  Future<void> _onLoadConditionalProbabilities(
    LoadConditionalProbabilities event,
    Emitter<AnalysisState> emit,
  ) async {
    final currentState = state;
    TrendAnalysis? existingTrendData;
    ConditionalProbabilityResult? existingProbabilityData;

    if (currentState is AnalysisLoaded) {
      existingTrendData = currentState.trendData;
      existingProbabilityData = currentState.probabilityData;
    } else if (currentState is AnalysisLoading) {
      existingTrendData = currentState.previousTrendData;
      existingProbabilityData = currentState.previousProbabilityData;
    }

    emit(AnalysisLoading(
      previousTrendData: existingTrendData,
      previousProbabilityData: existingProbabilityData,
    ));

    final result = await getConditionalProbabilities(
      Params(behaviorId: event.behaviorDefinitionId),
    );
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (data) => emit(AnalysisLoaded(
        probabilityData: data, 
        trendData: existingTrendData
      )),
    );
  }
}
