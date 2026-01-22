import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/behavior_definition_model.dart';

/// Remote data source for behavior definitions using Supabase
abstract class BehaviorDefinitionRemoteDataSource {
  /// Create a new behavior definition in Supabase
  Future<BehaviorDefinitionModel> createDefinition(BehaviorDefinitionModel model);
  
  /// Get all behavior definitions for the current user
  Future<List<BehaviorDefinitionModel>> getDefinitions();
  
  /// Watch behavior definitions with real-time updates
  Stream<List<BehaviorDefinitionModel>> watchDefinitions();
  
  /// Update an existing behavior definition
  Future<BehaviorDefinitionModel> updateDefinition(BehaviorDefinitionModel model);
  
  /// Delete a behavior definition
  Future<void> deleteDefinition(String id);
}

/// Implementation of BehaviorDefinitionRemoteDataSource using Supabase
class BehaviorDefinitionRemoteDataSourceImpl implements BehaviorDefinitionRemoteDataSource {
  final SupabaseClient supabaseClient;

  BehaviorDefinitionRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<BehaviorDefinitionModel> createDefinition(BehaviorDefinitionModel model) async {
    try {
      final response = await supabaseClient
          .from('behavior_definitions')
          .insert(model.toJson())
          .select()
          .single();
      
      return BehaviorDefinitionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to create behavior definition');
    }
  }

  @override
  Future<List<BehaviorDefinitionModel>> getDefinitions() async {
    try {
      final response = await supabaseClient
          .from('behavior_definitions')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => BehaviorDefinitionModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to fetch behavior definitions');
    }
  }

  @override
  Stream<List<BehaviorDefinitionModel>> watchDefinitions() {
    try {
      return supabaseClient
          .from('behavior_definitions')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((data) => data
              .map((json) => BehaviorDefinitionModel.fromJson(json))
              .toList());
    } catch (e) {
      throw ServerException('Failed to watch behavior definitions');
    }
  }

  @override
  Future<BehaviorDefinitionModel> updateDefinition(BehaviorDefinitionModel model) async {
    try {
      final response = await supabaseClient
          .from('behavior_definitions')
          .update(model.toJson())
          .eq('id', model.id)
          .select()
          .single();
      
      return BehaviorDefinitionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to update behavior definition');
    }
  }

  @override
  Future<void> deleteDefinition(String id) async {
    try {
      await supabaseClient
          .from('behavior_definitions')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to delete behavior definition');
    }
  }
}
