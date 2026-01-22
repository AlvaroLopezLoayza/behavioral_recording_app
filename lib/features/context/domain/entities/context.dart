import 'package:equatable/equatable.dart';

class Context extends Equatable {
  final String id;
  final String patientId;
  final String name;
  final String description;
  final String type; // e.g., 'physical', 'social', 'activity'
  final String createdBy;
  final DateTime createdAt;

  const Context({
    required this.id,
    required this.patientId,
    required this.name,
    this.description = '',
    this.type = 'physical',
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, patientId, name, description, type, createdBy, createdAt];
}
