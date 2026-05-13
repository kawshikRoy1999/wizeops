import 'package:dio/dio.dart';
import '../../core/errors/exceptions.dart';
import '../models/checklist_models.dart';

abstract class ChecklistRemoteDataSource {
  Future<ChecklistResponseModel> getAssignedChecklists(
      ChecklistRequestModel request);
}

class ChecklistRemoteDataSourceImpl implements ChecklistRemoteDataSource {
  final Dio dio;
  const ChecklistRemoteDataSourceImpl(this.dio);

  @override
  Future<ChecklistResponseModel> getAssignedChecklists(
      ChecklistRequestModel request) async {
    try {
      final response = await dio.post(
        '/Setting/GetAssignedCheckedList',
        data: request.toJson(),
      );
      final model = ChecklistResponseModel.fromJson(
          response.data as Map<String, dynamic>);
      if (!model.status) {
        throw ServerException(
            model.message.isNotEmpty ? model.message : 'Failed to load checklists');
      }
      return model;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('No internet connection');
      }
      final msg = e.response?.data?['message'] as String?;
      throw ServerException(msg ?? 'Server error');
    }
  }
}
