import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/context_model.dart';

abstract class ContextRemoteDataSource {
  Future<ContextModel> createContext(ContextModel context);
  Future<List<ContextModel>> getContextsForPatient(String patientId);
  Future<void> deleteContext(String id);
}

class ContextRemoteDataSourceImpl implements ContextRemoteDataSource {
  final SupabaseClient client;

  ContextRemoteDataSourceImpl({required this.client});

  @override
  Future<ContextModel> createContext(ContextModel context) async {
    try {
      final data = await client
          .from('contexts')
          .insert(context.toJson())
          .select()
          .single();
      return ContextModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ContextModel>> getContextsForPatient(String patientId) async {
    try {
      final data = await client
          .from('contexts')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);
      
      return (data as List).map((json) => ContextModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteContext(String id) async {
    try {
      await client.from('contexts').delete().eq('id', id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
