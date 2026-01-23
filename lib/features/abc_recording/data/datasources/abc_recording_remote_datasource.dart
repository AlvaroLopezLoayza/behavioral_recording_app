import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/abc_record_model.dart';
import '../models/recording_session_model.dart';

abstract class AbcRecordingRemoteDataSource {
  Future<AbcRecordModel> createAbcRecord(AbcRecordModel model);
  Future<List<AbcRecordModel>> getRecordsByBehavior(String behaviorDefinitionId);
  Future<List<AbcRecordModel>> getRecordsBySession(String sessionId);
  Future<List<RecordingSessionModel>> getSessionsByPatient(String patientId);
  Future<RecordingSessionModel> createRecordingSession(RecordingSessionModel model);
  Future<void> deleteRecord(String id);
}

class AbcRecordingRemoteDataSourceImpl implements AbcRecordingRemoteDataSource {
  final SupabaseClient supabaseClient;

  AbcRecordingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<AbcRecordModel> createAbcRecord(AbcRecordModel model) async {
    try {
      final response = await supabaseClient
          .from('abc_records')
          .insert(model.toJson())
          .select()
          .single();
      
      return AbcRecordModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to create ABC record');
    }
  }

  @override
  Future<List<AbcRecordModel>> getRecordsByBehavior(String behaviorDefinitionId) async {
    try {
      final response = await supabaseClient
          .from('abc_records')
          .select()
          .eq('behavior_definition_id', behaviorDefinitionId)
          .order('timestamp', ascending: false);
      
      return (response as List)
          .map((json) => AbcRecordModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to fetch ABC records');
    }
  }

  @override
  Future<List<AbcRecordModel>> getRecordsBySession(String sessionId) async {
    try {
      final response = await supabaseClient
          .from('abc_records')
          .select()
          .eq('session_id', sessionId)
          .order('timestamp', ascending: false);
      
      return (response as List)
          .map((json) => AbcRecordModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to fetch session records');
    }
  }

  @override
  Future<List<RecordingSessionModel>> getSessionsByPatient(String patientId) async {
    try {
      final response = await supabaseClient
          .from('recording_sessions')
          .select()
          .eq('patient_id', patientId)
          .order('start_time', ascending: false);
      
      return (response as List)
          .map((json) => RecordingSessionModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to fetch sessions');
    }
  }

  @override
  Future<RecordingSessionModel> createRecordingSession(RecordingSessionModel model) async {
    try {
      final response = await supabaseClient
          .from('recording_sessions')
          .insert(model.toJson())
          .select()
          .single();
      
      return RecordingSessionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to create recording session');
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    try {
      await supabaseClient
          .from('abc_records')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to delete ABC record');
    }
  }
}
