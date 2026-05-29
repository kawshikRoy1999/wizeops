import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required int companyId,
    required String userName,
    required String password,
    required bool rememberMe,
  });

  Future<void> logout();
  Future<UserEntity?> getCachedUser();
  Future<bool> getRememberMe();
}
