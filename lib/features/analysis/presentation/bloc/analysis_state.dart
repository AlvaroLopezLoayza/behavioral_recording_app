import '../../domain/entities/conditional_probability.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();
  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}
class AnalysisLoading extends AnalysisState {}
class AnalysisLoaded extends AnalysisState {
  final TrendAnalysis? trendData;
  final ConditionalProbabilityResult? probabilityData;

  const AnalysisLoaded({
    this.trendData,
    this.probabilityData,
  });

  @override
  List<Object?> get props => [trendData, probabilityData];
}
class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
  @override
  List<Object?> get props => [message];
}
