import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/upload_file_model.dart';

abstract class UploadFileDataSource {
  /// Uploads a single file for a given checklist label.
  /// Maps to: POST /Setting/UploadCheckListFile
  /// Form fields: files (IFormFile), checklistIds (int)
  Future<UploadedFileModel> uploadFile({
    required int labelId,
    required String filePath,
    required String fileName,
    required String contentType,
  });
}

class UploadFileDataSourceImpl implements UploadFileDataSource {
  final Dio _dio;
  UploadFileDataSourceImpl(this._dio);

  @override
  Future<UploadedFileModel> uploadFile({
    required int labelId,
    required String filePath,
    required String fileName,
    required String contentType,
  }) async {
    // Build multipart form exactly as the .NET endpoint expects:
    //   files        → IFormFileCollection (Request.Form.Files)
    //   checklistIds → StringValues (Request.Form["checklistIds"])
    final formData = FormData();

    formData.files.add(MapEntry(
      'files',
      await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: DioMediaType.parse(contentType),
      ),
    ));

    formData.fields.add(MapEntry('checklistIds', labelId.toString()));

    // No Options override needed — with Content-Type removed from DioClient's
    // global headers, Dio auto-sets 'multipart/form-data; boundary=...'
    // correctly when the data is FormData.
    final response = await _dio.post(
      '/Setting/UploadCheckListFile',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Content-Type': null}, // remove global json header
      ),
    );

    final responseData = response.data is String
        ? Map<String, dynamic>.from(jsonDecode(response.data as String))
        : response.data as Map<String, dynamic>;

    final parsed = UploadFileResponse.fromJson(responseData);

    if (!parsed.status || parsed.data.isEmpty) {
      throw Exception(parsed.message.isNotEmpty
          ? parsed.message
          : 'Upload failed — no data returned');
    }

    return parsed.data.first;
  }

  /// Detect MIME type from file extension.
  static String mimeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'heic': 'image/heic',
      'webp': 'image/webp',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}
