import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_behavior_trend.dart';
import '../../domain/usecases/get_conditional_probabilities.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final GetBehaviorTrend getBehaviorTrend;
  final GetConditionalProbabilities getConditionalProbabilities;

  AnalysisBloc({
    required this.getBehaviorTrend,
    required this.getConditionalProbabilities,
  }) : super(AnalysisInitial()) {
    on<LoadTrendAnalysis>(_onLoadTrendAnalysis);
    on<LoadConditionalProbabilities>(_onLoadConditionalProbabilities);
  }

  Future<void> _onLoadTrendAnalysis(
    LoadTrendAnalysis event,
    Emitter<AnalysisState> emit,
  ) async {
    final currentState = state;
    ConditionalProbabilityResult? existingProbabilityData;
    if (currentState is AnalysisLoaded) {
      existingProbabilityData = currentState.probabilityData;
    }
    
    emit(AnalysisLoading());
    final result = await getBehaviorTrend(
      GetBehaviorTrendParams(behaviorDefinitionId: event.behaviorDefinitionId),
    );
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (data) => emit(AnalysisLoaded(trendData: data, probabilityData: existingProbabilityData)),
    );
  }

  Future<void> _onLoadConditionalProbabilities(
    LoadConditionalProbabilities event,
    Emitter<AnalysisState> emit,
  ) async {
    final currentState = state;
    TrendAnalysis? existingTrendData;
    if (currentState is AnalysisLoaded) {
      existingTrendData = currentState.trendData;
    }

    emit(AnalysisLoading());
    final result = await getConditionalProbabilities(
      Params(behaviorId: event.behaviorDefinitionId),
    );
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (data) => emit(AnalysisLoaded(probabilityData: data, trendData: existingTrendData)),
    );
  }
}
