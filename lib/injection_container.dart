import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ABC Recording Feature
import 'features/abc_recording/data/datasources/abc_recording_remote_datasource.dart';
import 'features/abc_recording/data/repositories/abc_recording_repository_impl.dart';
import 'features/abc_recording/domain/repositories/abc_recording_repository.dart';
import 'features/abc_recording/domain/usecases/create_abc_record.dart';
import 'features/abc_recording/domain/usecases/get_records_by_behavior.dart';
import 'features/abc_recording/presentation/bloc/abc_recording_bloc.dart';
// Analysis Feature
import 'features/analysis/domain/usecases/get_behavior_trend.dart';
import 'features/analysis/domain/usecases/get_conditional_probabilities.dart';
import 'features/analysis/presentation/bloc/analysis_bloc.dart';
// Authentication Feature
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/auth_usecases.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
// Features
import 'features/behavior_definition/data/datasources/behavior_definition_remote_datasource.dart';
import 'features/behavior_definition/data/repositories/behavior_definition_repository_impl.dart';
import 'features/behavior_definition/domain/repositories/behavior_definition_repository.dart';
import 'features/behavior_definition/domain/usecases/create_behavior_definition.dart';
import 'features/behavior_definition/domain/usecases/get_behavior_definitions.dart';
import 'features/behavior_definition/presentation/bloc/behavior_definition_bloc.dart';
// Context Feature
import 'features/context/data/datasources/context_remote_datasource.dart';
import 'features/context/data/repositories/context_repository_impl.dart';
import 'features/context/domain/repositories/context_repository.dart';
import 'features/context/presentation/bloc/context_bloc.dart';
// Hypothesis Feature
import 'features/hypothesis/data/datasources/hypothesis_remote_datasource.dart';
import 'features/hypothesis/data/repositories/hypothesis_repository_impl.dart';
import 'features/hypothesis/domain/repositories/hypothesis_repository.dart';
import 'features/hypothesis/presentation/bloc/hypothesis_bloc.dart';
// Intervention Feature
import 'features/intervention/data/datasources/intervention_remote_datasource.dart';
import 'features/intervention/data/repositories/intervention_repository_impl.dart';
import 'features/intervention/domain/repositories/intervention_repository.dart';
import 'features/intervention/domain/usecases/get_phase_changes.dart';
import 'features/intervention/presentation/bloc/intervention_bloc.dart';
// Patient Feature
import 'features/patient/data/datasources/patient_remote_datasource.dart';
import 'features/patient/data/repositories/patient_repository_impl.dart';
import 'features/patient/domain/repositories/patient_repository.dart';
import 'features/patient/domain/usecases/get_patient_by_id.dart';
import 'features/patient/presentation/bloc/patient_access_bloc.dart';
import 'features/patient/presentation/bloc/patient_bloc.dart';
// Reliability Feature
import 'features/reliability/data/datasources/reliability_remote_datasource.dart';
import 'features/reliability/data/repositories/reliability_repository_impl.dart';
import 'features/reliability/domain/repositories/reliability_repository.dart';
import 'features/reliability/domain/usecases/calculate_ioa.dart';
import 'features/reliability/domain/usecases/get_reliability_records.dart';
import 'features/reliability/domain/usecases/save_reliability_record.dart';
import 'features/reliability/presentation/bloc/reliability_bloc.dart';
import 'features/reliability/presentation/bloc/reliability_bloc.dart';
// Workflow Feature
import 'features/workflow/presentation/bloc/workflow_bloc.dart';
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Data sources
  sl.registerLazySingleton<BehaviorDefinitionRemoteDataSource>(
    () => BehaviorDefinitionRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<BehaviorDefinitionRepository>(
    () => BehaviorDefinitionRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<AbcRecordingRemoteDataSource>(
    () => AbcRecordingRemoteDataSourceImpl(supabaseClient: sl()),
  );
  
  sl.registerLazySingleton<AbcRecordingRepository>(
    () => AbcRecordingRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<HypothesisRemoteDataSource>(
    () => HypothesisRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<HypothesisRepository>(
    () => HypothesisRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateBehaviorDefinition(sl()));
  sl.registerLazySingleton(() => GetBehaviorDefinitions(sl()));
  
  sl.registerLazySingleton(() => CreateAbcRecord(sl()));
  sl.registerLazySingleton(() => GetRecordsByBehavior(sl()));
  
  sl.registerLazySingleton(() => GetBehaviorTrend(sl(), sl()));
  sl.registerLazySingleton(() => GetConditionalProbabilities(sl()));
  
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // BLoCs
  sl.registerFactory(
    () => BehaviorDefinitionBloc(
      getBehaviorDefinitions: sl(),
      createBehaviorDefinition: sl(),
    ),
  );
  
  sl.registerFactory(
    () => AbcRecordingBloc(
      createAbcRecord: sl(),
      getRecordsByBehavior: sl(),
    ),
  );
  
  sl.registerFactory(
    () => AnalysisBloc(
      getBehaviorTrend: sl(),
      getConditionalProbabilities: sl(),
      getPhaseChanges: sl(),
    ),
  );
  
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Patient Feature
  sl.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(
    () => PatientBloc(
      repository: sl(),
      supabaseClient: sl(),
    ),
  );
  
  sl.registerFactory(
    () => PatientAccessBloc(
      repository: sl(),
    ),
  );

  // Context Feature
  sl.registerLazySingleton<ContextRemoteDataSource>(
    () => ContextRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<ContextRepository>(
    () => ContextRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(
    () => ContextBloc(
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => HypothesisBloc(
      repository: sl(),
    ),
  );

  // Intervention Feature
  sl.registerLazySingleton<InterventionRemoteDataSource>(
    () => InterventionRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<InterventionRepository>(
    () => InterventionRepositoryImpl(sl()),
  );

  sl.registerFactory(
    () => InterventionBloc(
      repository: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetPhaseChanges(sl()));
  sl.registerLazySingleton(() => GetPatientById(sl()));

  // Reliability Feature
  sl.registerLazySingleton<ReliabilityRemoteDataSource>(
    () => ReliabilityRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ReliabilityRepository>(
    () => ReliabilityRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => CalculateIOA(sl()));
  sl.registerLazySingleton(() => GetReliabilityRecords(sl()));
  sl.registerLazySingleton(() => SaveReliabilityRecord(sl()));

  sl.registerFactory(
    () => ReliabilityBloc(
      calculateIOA: sl(),
      getReliabilityRecords: sl(),
      saveReliabilityRecord: sl(),
    ),
  );

  sl.registerFactory(
    () => WorkflowBloc(),
  );
}
