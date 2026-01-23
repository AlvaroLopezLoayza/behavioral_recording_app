import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reliability_record_model.dart';

abstract class ReliabilityRemoteDataSource {
  Future<List<ReliabilityRecordModel>> getReliabilityByPatient(String patientId);
  Future<ReliabilityRecordModel> saveReliabilityRecord(ReliabilityRecordModel record);
  Future<List<Map<String, dynamic>>> getABCRecordsForIOA({
    required String behaviorDefinitionId,
    required String observerId,
    required DateTime startTime,
    required DateTime endTime,
  });
}

class ReliabilityRemoteDataSourceImpl implements ReliabilityRemoteDataSource {
  final SupabaseClient supabase;

  ReliabilityRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<ReliabilityRecordModel>> getReliabilityByPatient(String patientId) async {
    final response = await supabase
        .from('reliability_records')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => ReliabilityRecordModel.fromJson(json)).toList();
  }

  @override
  Future<ReliabilityRecordModel> saveReliabilityRecord(ReliabilityRecordModel record) async {
    final response = await supabase
        .from('reliability_records')
        .insert(record.toJson())
        .select()
        .single();

    return ReliabilityRecordModel.fromJson(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getABCRecordsForIOA({
    required String behaviorDefinitionId,
    required String observerId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final response = await supabase
        .from('abc_records')
        .select('id, timestamp, recording_type')
        .eq('behavior_definition_id', behaviorDefinitionId)
        .eq('observer_id', observerId)
        .gte('timestamp', startTime.toIso8601String())
        .lte('timestamp', endTime.toIso8601String());

    return List<Map<String, dynamic>>.from(response);
  }
}
