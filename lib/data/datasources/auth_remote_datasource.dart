import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserDataModel> login(LoginRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserDataModel> login(LoginRequestModel request) async {
    try {
      final response = await dio.post(
        ApiConstants.authenticate,
        data: request.toJson(),
      );

      final loginResponse = LoginResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!loginResponse.status || loginResponse.data == null) {
        throw ServerException(
          loginResponse.message.isNotEmpty
              ? loginResponse.message
              : 'Authentication failed',
        );
      }

      return loginResponse.data!;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid credentials');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      }
      final message = e.response?.data?['message'] as String?;
      throw ServerException(message ?? 'Server error occurred');
    }
  }
}
