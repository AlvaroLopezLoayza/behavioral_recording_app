import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_behavior_trend.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final GetBehaviorTrend getBehaviorTrend;

  AnalysisBloc({required this.getBehaviorTrend}) : super(AnalysisInitial()) {
    on<LoadTrendAnalysis>(_onLoadTrendAnalysis);
  }

  Future<void> _onLoadTrendAnalysis(
    LoadTrendAnalysis event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(AnalysisLoading());
    final result = await getBehaviorTrend(
      GetBehaviorTrendParams(behaviorDefinitionId: event.behaviorDefinitionId),
    );
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (data) => emit(AnalysisLoaded(data)),
    );
  }
}
