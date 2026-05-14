import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/submit_checklist_model.dart';

abstract class SubmitChecklistDataSource {
  Future<SubmitChecklistResponse> submit(SubmitChecklistRequest request);
}

class SubmitChecklistDataSourceImpl implements SubmitChecklistDataSource {
  final Dio _dio;
  SubmitChecklistDataSourceImpl(this._dio);

  @override
  Future<SubmitChecklistResponse> submit(SubmitChecklistRequest request) async {
    final response = await _dio.post(
      '/Setting/AddEditAssignedCheckedList',
      data: request.toJson(),
    );

    final responseData = response.data is String
        ? Map<String, dynamic>.from(jsonDecode(response.data as String))
        : response.data as Map<String, dynamic>;

    return SubmitChecklistResponse.fromJson(responseData);
  }
}
