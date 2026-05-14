import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart'; // XFile handles content:// URIs on Android
import '../../core/constants/api_constants.dart';
import '../models/upload_file_model.dart';

abstract class UploadFileDataSource {
  /// Uploads a single file for a given checklist label.
  /// Maps to: POST /Setting/UploadCheckListFile
  /// Body (JSON):
  ///   file               → base64-encoded byte[]
  ///   checklistIds       → int
  ///   ImageFilePath      → user's existing image path
  ///   ImageType          → 6 (hardcoded)
  ///   CompanyId          → user's company id
  ///   Name               → file display name
  ///   FileName           → file name with extension
  ///   ContentDescription → content-disposition header value
  ///   ContentType        → MIME type
  Future<UploadedFileModel> uploadFile({
    required int labelId,
    required String filePath,
    required String fileName,
    required String contentType,
    required int companyId,
    required String imageFilePath,
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
    required int companyId,
    required String imageFilePath,
  }) async {
    // XFile handles both regular file paths AND Android content:// URIs.
    // dart:io File() only works with real paths and throws
    // "Invalid URI: The hostname could not be parsed" for content:// URIs.
    final bytes = await XFile(filePath).readAsBytes();
    final base64File = base64Encode(bytes);

    // Name = display name (filename without extension)
    final name = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    // ContentDescription mimics the Content-Disposition header value
    final contentDescription = 'attachment; filename="$fileName"';

    final body = {
      'file': base64File,
      'checklistIds': labelId,
      // Send null when empty — .NET throws UriFormatException on new Uri("")
      'ImageFilePath': ApiConstants.uploadImageBasePath,
      'ImageType': 6,
      'CompanyId': companyId,
      'Name': fileName,
      'FileName': fileName,
      'ContentDescription': contentDescription,
      'ContentType': contentType,
    };

    final response = await _dio.post(
      '/Setting/UploadCheckListFile',
      data: body,
    );

    final responseData = response.data is String
        ? Map<String, dynamic>.from(jsonDecode(response.data as String))
        : response.data as Map<String, dynamic>;

    final parsed = UploadFileResponse.fromJson(responseData);

    if (!parsed.status || parsed.data == null) {
      throw Exception(parsed.message.isNotEmpty
          ? parsed.message
          : 'Upload failed — no data returned');
    }

    return parsed.data!;
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
