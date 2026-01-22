import 'package:equatable/equatable.dart';

class DailyFrequency extends Equatable {
  final DateTime date;
  final int count;

  const DailyFrequency({required this.date, required this.count});

  @override
  List<Object?> get props => [date, count];
}

class TrendAnalysis extends Equatable {
  final String behaviorId;
  final List<DailyFrequency> dataPoints;
  final double averageFrequency;
  final int maxFrequency;

  const TrendAnalysis({
    required this.behaviorId,
    required this.dataPoints,
    required this.averageFrequency,
    required this.maxFrequency,
  });

  @override
  List<Object?> get props => [behaviorId, dataPoints, averageFrequency, maxFrequency];
}
