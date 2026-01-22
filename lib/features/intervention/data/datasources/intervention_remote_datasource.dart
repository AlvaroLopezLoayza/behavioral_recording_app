import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/intervention_plan_model.dart';

abstract class InterventionRemoteDataSource {
  Future<List<InterventionPlanModel>> getPlansByHypothesis(String hypothesisId);
  Future<InterventionPlanModel> createPlan(InterventionPlanModel plan);
  Future<InterventionPlanModel> updatePlan(InterventionPlanModel plan);
  Future<void> deletePlan(String planId);
}

class InterventionRemoteDataSourceImpl implements InterventionRemoteDataSource {
  final SupabaseClient client;

  InterventionRemoteDataSourceImpl(this.client);

  @override
  Future<List<InterventionPlanModel>> getPlansByHypothesis(String hypothesisId) async {
    final response = await client
        .from('intervention_plans')
        .select()
        .eq('hypothesis_id', hypothesisId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => InterventionPlanModel.fromJson(json)).toList();
  }

  @override
  Future<InterventionPlanModel> createPlan(InterventionPlanModel plan) async {
    final response = await client
        .from('intervention_plans')
        .insert(plan.toJson())
        .select()
        .single();
    
    return InterventionPlanModel.fromJson(response);
  }

  @override
  Future<InterventionPlanModel> updatePlan(InterventionPlanModel plan) async {
    final response = await client
        .from('intervention_plans')
        .update(plan.toJson())
        .eq('id', plan.id)
        .select()
        .single();
    
    return InterventionPlanModel.fromJson(response);
  }

  @override
  Future<void> deletePlan(String planId) async {
    await client.from('intervention_plans').delete().eq('id', planId);
  }
}
