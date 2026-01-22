import '../../domain/entities/access_role.dart';
import '../../domain/entities/patient_access.dart';

class PatientAccessModel extends PatientAccess {
  const PatientAccessModel({
    required super.id,
    required super.patientId,
    required super.userId,
    super.userEmail,
    required super.role,
    required super.grantedBy,
    required super.createdAt,
  });

  factory PatientAccessModel.fromJson(Map<String, dynamic> json) {
    return PatientAccessModel(
      id: json['id'],
      patientId: json['patient_id'],
      userId: json['user_id'],
      // Supabase join query might return user email in a nested object, 
      // or we might join it manually. Assuming a view or join:
      userEmail: json['users'] != null ? json['users']['email'] : null,
      role: AccessRole.fromString(json['role']),
      grantedBy: json['granted_by'] ?? '', // Should be present
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'user_id': userId,
      'role': role.toStringValue,
      'granted_by': grantedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
  PatientAccessModel copyWith({
    String? id,
    String? patientId,
    String? userId,
    String? userEmail,
    AccessRole? role,
    String? grantedBy,
    DateTime? createdAt,
  }) {
    return PatientAccessModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      role: role ?? this.role,
      grantedBy: grantedBy ?? this.grantedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
