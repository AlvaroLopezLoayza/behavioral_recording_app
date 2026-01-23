import 'package:equatable/equatable.dart';

abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();
  @override
  List<Object?> get props => [];
}

class LoadTrendAnalysis extends AnalysisEvent {
  final String behaviorDefinitionId;
  const LoadTrendAnalysis(this.behaviorDefinitionId);
  @override
  List<Object?> get props => [behaviorDefinitionId];
}

class LoadConditionalProbabilities extends AnalysisEvent {
  final String behaviorDefinitionId;
  const LoadConditionalProbabilities(this.behaviorDefinitionId);
  @override
  List<Object?> get props => [behaviorDefinitionId];
}
