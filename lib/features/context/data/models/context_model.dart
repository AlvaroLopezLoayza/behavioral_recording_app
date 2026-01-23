import '../domain/entities/clinical_context.dart';

class ContextModel extends ClinicalContext {
  const ContextModel({
    required String id,
    required String patientId,
    required String name,
    String description = '',
    String type = 'physical',
    required String createdBy,
    required DateTime createdAt,
  }) : super(
          id: id,
          patientId: patientId,
          name: name,
          description: description,
          type: type,
          createdBy: createdBy,
          createdAt: createdAt,
        );

  factory ContextModel.fromJson(Map<String, dynamic> json) {
    return ContextModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'physical',
      createdBy: json['created_by'] as String? ?? '', // Often omitted in select, handle carefully
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'name': name,
      'description': description,
      'type': type,
      // 'created_by' is usually handled by Supabase auth.uid() default or RLS
      // 'created_at' is handled by default
    };
  }

  factory ContextModel.fromEntity(ClinicalContext context) {
    return ContextModel(
      id: context.id,
      patientId: context.patientId,
      name: context.name,
      description: context.description,
      type: context.type,
      createdBy: context.createdBy,
      createdAt: context.createdAt,
    );
  }
}
