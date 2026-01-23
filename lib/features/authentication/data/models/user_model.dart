import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
  });

  factory UserModel.fromSupabase(sb.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
    );
  }
}
