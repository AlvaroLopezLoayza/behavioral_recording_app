import '../../domain/entities/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    required String id,
    required String firstName,
    required String lastName,
    DateTime? birthDate,
    String? diagnosis,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          birthDate: birthDate,
          diagnosis: diagnosis,
          ownerId: ownerId,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      diagnosis: json['diagnosis'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.parse(json['created_at']), // Fallback
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate?.toIso8601String(),
      'diagnosis': diagnosis,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PatientModel.fromEntity(Patient patient) {
    return PatientModel(
      id: patient.id,
      firstName: patient.firstName,
      lastName: patient.lastName,
      birthDate: patient.birthDate,
      diagnosis: patient.diagnosis,
      ownerId: patient.ownerId,
      createdAt: patient.createdAt,
      updatedAt: patient.updatedAt,
    );
  }
}
