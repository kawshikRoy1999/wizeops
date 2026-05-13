import 'package:dio/dio.dart';
import '../../core/errors/exceptions.dart';
import '../models/checklist_detail_models.dart';

abstract class ChecklistDetailRemoteDataSource {
  Future<ChecklistDetailDataModel> getChecklistDetails(
      ChecklistDetailRequestModel request);
}

class ChecklistDetailRemoteDataSourceImpl
    implements ChecklistDetailRemoteDataSource {
  final Dio dio;
  const ChecklistDetailRemoteDataSourceImpl(this.dio);

  @override
  Future<ChecklistDetailDataModel> getChecklistDetails(
      ChecklistDetailRequestModel request) async {
    try {
      final response = await dio.post(
        '/Setting/GetAssignedCheckedListDetails',
        data: request.toJson(),
      );
      final model = ChecklistDetailResponseModel.fromJson(
          response.data as Map<String, dynamic>);
      if (!model.status || model.data == null) {
        throw ServerException(model.message.isNotEmpty
            ? model.message
            : 'Failed to load checklist details');
      }
      return model.data!;
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
