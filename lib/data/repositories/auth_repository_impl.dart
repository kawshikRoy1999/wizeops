import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required int companyId,
    required String userName,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final request = LoginRequestModel(
        companyId: companyId,
        userName: userName,
        password: password,
        rememberMe: rememberMe,
      );

      final userModel = await remoteDataSource.login(request);

      await secureStorage.write(
        key: AppConstants.tokenKey,
        value: userModel.token,
      );
      await secureStorage.write(
        key: AppConstants.companyIdKey,
        value: userModel.companyId.toString(),
      );
      await secureStorage.write(
        key: AppConstants.rememberMeKey,
        value: rememberMe ? '1' : '0',
      );

      final entity = userModel.toEntity();
      await _cacheUser(userModel);

      return Right(entity);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: AppConstants.tokenKey);
    await secureStorage.delete(key: AppConstants.userKey);
    await secureStorage.delete(key: AppConstants.companyIdKey);
    await secureStorage.delete(key: AppConstants.rememberMeKey);
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    try {
      final raw = await secureStorage.read(key: AppConstants.userKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserDataModel.fromJson(json).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> getRememberMe() async {
    final val = await secureStorage.read(key: AppConstants.rememberMeKey);
    return val == '1';
  }

  Future<void> _cacheUser(UserDataModel model) async {
    final json = jsonEncode({
      'id': model.id,
      'companyId': model.companyId,
      'firstName': model.firstName,
      'lastName': model.lastName,
      'middleName': model.middleName,
      'userEmail': model.userEmail,
      'phone': model.phone,
      'token': model.token,
      'roles': model.roles,
      'userName': model.userName,
      'isActive': model.isActive,
      'isCustomer': model.isCustomer,
      'userPhoneCode': model.userPhoneCode,
      'userPhoneCountryCode': model.userPhoneCountryCode,
      'currencyCode': model.currencyCode,
      'dateFormat': model.dateFormat,
      'posToken': model.posToken,
      'imageFilePath': model.imageFilePath,
    });
    await secureStorage.write(key: AppConstants.userKey, value: json);
  }
}
