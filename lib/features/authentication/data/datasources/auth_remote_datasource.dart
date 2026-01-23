import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart' hide AuthException;
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<AuthState> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) throw ServerException('User not found after sign in');
      return UserModel.fromSupabase(response.user!);
    } on AuthException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.senda://login-callback',
      );
      if (response.user == null) throw ServerException('User creation failed');
      return UserModel.fromSupabase(response.user!);
    } on AuthException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      return UserModel.fromSupabase(user);
    }
    return null;
  }

  @override
  Stream<AuthState> get authStateChanges => supabaseClient.auth.onAuthStateChange;
}
