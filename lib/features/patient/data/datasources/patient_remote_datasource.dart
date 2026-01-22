import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/patient_model.dart';
import '../models/patient_access_model.dart';
import '../../domain/entities/access_role.dart';

abstract class PatientRemoteDataSource {
  Future<PatientModel> createPatient(PatientModel patient);
  Future<List<PatientModel>> getPatients();
  Future<PatientModel> getPatientById(String id);
  Future<List<PatientAccessModel>> getPatientAccesses(String patientId);
  Future<PatientAccessModel> sharePatient(String patientId, String email, AccessRole role);
  Future<void> revokeAccess(String accessId);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final SupabaseClient supabaseClient;

  PatientRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<PatientModel> createPatient(PatientModel patient) async {
    try {
      final response = await supabaseClient
          .from('patients')
          .insert(patient.toJson())
          .select()
          .single();
      return PatientModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PatientModel>> getPatients() async {
    try {
      // Logic: Get patients where user is owner OR has access record
      // This logic is mostly handled by RLS, so simple select works
      final response = await supabaseClient.from('patients').select();
      return (response as List).map((e) => PatientModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      final response = await supabaseClient
          .from('patients')
          .select()
          .eq('id', id)
          .single();
      return PatientModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PatientAccessModel>> getPatientAccesses(String patientId) async {
    try {
      // We need to join with users table (or a public profiles table) to get emails
      // Note: Supabase user emails are private by default in `auth.users`. 
      // We might need a secure function or a `public_users` table synced via triggers.
      // For MVP, we will assume a query that joins or just returns the data accessible via RLS on `patient_access`.
      final response = await supabaseClient
          .from('patient_access')
          .select()
          .eq('patient_id', patientId);
          
      return (response as List).map((e) => PatientAccessModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PatientAccessModel> sharePatient(String patientId, String email, AccessRole role) async {
    try {
      // 1. Get User ID by Email using secured RPC
      final targetUserId = await supabaseClient.rpc(
        'get_user_id_by_email', 
        params: {'email_input': email}
      );

      if (targetUserId == null) {
        throw ServerException("Usuario no encontrado con este email");
      }

      // 2. Grant Access
      final currentUserId = supabaseClient.auth.currentUser!.id;
      final response = await supabaseClient
          .from('patient_access')
          .insert({
            'patient_id': patientId,
            'user_id': targetUserId,
            'role': role.toStringValue,
            'granted_by': currentUserId,
          })
          .select()
          .single();
          
      // Note: The response might not contain user email immediately unless we join.
      // For now, we return the object with null email or passed email manually if needed.
      // Ideally we fetch the view again.
      return PatientAccessModel.fromJson(response).copyWith(
        userEmail: email, // Manually enrich since we know it
      ); 
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
         throw ServerException("El usuario ya tiene acceso a este paciente");
      }
      throw ServerException(e.message);
    } catch (e) {
      if (e is ServerException) rethrow; // Pass simplified exceptions up
      // Handle generic "functions.execute" error if RPC fails
      throw ServerException("Error al compartir: ${e.toString()}");
    }
  }

  @override
  Future<void> revokeAccess(String accessId) async {
    try {
      await supabaseClient
          .from('patient_access')
          .delete()
          .eq('id', accessId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
