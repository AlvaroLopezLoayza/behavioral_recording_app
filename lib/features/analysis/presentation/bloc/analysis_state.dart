import 'package:equatable/equatable.dart';
import '../../domain/entities/conditional_probability.dart';
import '../../domain/entities/trend_analysis.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();
  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisLoading extends AnalysisState {
  final TrendAnalysis? previousTrendData;
  final ConditionalProbabilityResult? previousProbabilityData;

  const AnalysisLoading({
    this.previousTrendData,
    this.previousProbabilityData,
  });

  @override
  List<Object?> get props => [previousTrendData, previousProbabilityData];
}

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
