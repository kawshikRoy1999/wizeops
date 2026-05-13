import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.login(
      companyId: params.companyId,
      userName: params.userName,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}

class LoginParams extends Equatable {
  final int companyId;
  final String userName;
  final String password;
  final bool rememberMe;

  const LoginParams({
    required this.companyId,
    required this.userName,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object> get props => [companyId, userName, password, rememberMe];
}
