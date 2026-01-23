import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthParams {
  final String email;
  final String password;
  const AuthParams({required this.email, required this.password});
}

class SignIn implements UseCase<User, AuthParams> {
  final AuthRepository repository;
  SignIn(this.repository);

  @override
  Future<Either<Failure, User>> call(AuthParams params) {
    return repository.signIn(email: params.email, password: params.password);
  }
}

class SignUp implements UseCase<User, AuthParams> {
  final AuthRepository repository;
  SignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(AuthParams params) {
    return repository.signUp(email: params.email, password: params.password);
  }
}

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;
  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}

class GetCurrentUser implements UseCase<User, NoParams> {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
