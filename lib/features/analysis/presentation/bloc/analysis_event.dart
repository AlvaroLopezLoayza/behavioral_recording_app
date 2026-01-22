import 'package:equatable/equatable.dart';
import '../../domain/entities/trend_analysis.dart';

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
