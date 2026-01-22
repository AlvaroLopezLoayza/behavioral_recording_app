import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/behavior_definition/presentation/pages/behavior_definition_list_page.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';
import 'features/authentication/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Initialize dependency injection
  await di.initializeDependencies();
  
  runApp(const MyApp());
}

// Global Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
      child: MaterialApp(
        title: 'Behavioral Recording',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const BehaviorDefinitionListPage();
            } else if (state is Unauthenticated) {
              return const LoginPage();
            }
            // Show splash or loading while checking status
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}


