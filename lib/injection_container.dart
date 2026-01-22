import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Features
import 'features/behavior_definition/data/datasources/behavior_definition_remote_datasource.dart';
import 'features/behavior_definition/data/repositories/behavior_definition_repository_impl.dart';
import 'features/behavior_definition/domain/repositories/behavior_definition_repository.dart';
import 'features/behavior_definition/domain/usecases/create_behavior_definition.dart';
import 'features/behavior_definition/domain/usecases/get_behavior_definitions.dart';
import 'features/behavior_definition/presentation/bloc/behavior_definition_bloc.dart';

// ABC Recording Feature
import 'features/abc_recording/data/datasources/abc_recording_remote_datasource.dart';
import 'features/abc_recording/data/repositories/abc_recording_repository_impl.dart';
import 'features/abc_recording/domain/repositories/abc_recording_repository.dart';
import 'features/abc_recording/domain/usecases/create_abc_record.dart';
import 'features/abc_recording/domain/usecases/get_records_by_behavior.dart';
import 'features/abc_recording/presentation/bloc/abc_recording_bloc.dart';

// Analysis Feature
import 'features/analysis/domain/usecases/get_behavior_trend.dart';
import 'features/analysis/presentation/bloc/analysis_bloc.dart';

// Authentication Feature
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/auth_usecases.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

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

  // Use cases
  sl.registerLazySingleton(() => CreateBehaviorDefinition(sl()));
  sl.registerLazySingleton(() => GetBehaviorDefinitions(sl()));
  
  sl.registerLazySingleton(() => CreateAbcRecord(sl()));
  sl.registerLazySingleton(() => GetRecordsByBehavior(sl()));
  
  sl.registerLazySingleton(() => GetBehaviorTrend(sl()));
  
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
    () => AnalysisBloc(getBehaviorTrend: sl()),
  );
  
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );
}
