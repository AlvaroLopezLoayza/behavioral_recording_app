import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? diagnosis;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.diagnosis,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? diagnosis,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      diagnosis: diagnosis ?? this.diagnosis,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        birthDate,
        diagnosis,
        ownerId,
        createdAt,
        updatedAt,
      ];
}
