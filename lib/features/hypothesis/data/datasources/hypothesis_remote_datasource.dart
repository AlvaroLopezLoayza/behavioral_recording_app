import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/functional_hypothesis_model.dart';
import '../../domain/entities/functional_hypothesis.dart';

abstract class HypothesisRemoteDataSource {
  Future<FunctionalHypothesisModel> createHypothesis(FunctionalHypothesisModel hypothesis);
  Future<List<FunctionalHypothesisModel>> getHypothesesByBehavior(String behaviorId);
  Future<FunctionalHypothesisModel> updateHypothesis(FunctionalHypothesisModel hypothesis);
  Future<void> deleteHypothesis(String id);
}

class HypothesisRemoteDataSourceImpl implements HypothesisRemoteDataSource {
  final SupabaseClient client;

  HypothesisRemoteDataSourceImpl({required this.client});

  @override
  Future<FunctionalHypothesisModel> createHypothesis(FunctionalHypothesisModel hypothesis) async {
    try {
      final response = await client
          .from('functional_hypotheses')
          .insert(hypothesis.toJson())
          .select()
          .single();
      return FunctionalHypothesisModel.fromJson(response);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<FunctionalHypothesisModel>> getHypothesesByBehavior(String behaviorId) async {
    try {
      final response = await client
          .from('functional_hypotheses')
          .select()
          .eq('behavior_definition_id', behaviorId);
      
      return (response as List)
          .map((e) => FunctionalHypothesisModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<FunctionalHypothesisModel> updateHypothesis(FunctionalHypothesisModel hypothesis) async {
    try {
      final response = await client
          .from('functional_hypotheses')
          .update(hypothesis.toJson())
          .eq('id', hypothesis.id)
          .select()
          .single();
      return FunctionalHypothesisModel.fromJson(response);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteHypothesis(String id) async {
    try {
      await client.from('functional_hypotheses').delete().eq('id', id);
    } catch (e) {
      throw ServerException();
    }
  }
}
