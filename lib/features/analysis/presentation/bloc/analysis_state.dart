import 'package:equatable/equatable.dart';
import '../../domain/entities/trend_analysis.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();
  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}
class AnalysisLoading extends AnalysisState {}
class AnalysisLoaded extends AnalysisState {
  final TrendAnalysis data;
  const AnalysisLoaded(this.data);
  @override
  List<Object?> get props => [data];
}
class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
  @override
  List<Object?> get props => [message];
}
