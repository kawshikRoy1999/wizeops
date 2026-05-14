String _str(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

bool _parseBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

/// Maps to C#: ResUploadImage
class UploadedFileModel {
  final String imagePath;
  final String imageName;
  final int checklistLabelId;

  const UploadedFileModel({
    required this.imagePath,
    required this.imageName,
    required this.checklistLabelId,
  });

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) =>
      UploadedFileModel(
        imagePath: _str(json['ImagePath'] ?? json['imagePath']),
        imageName: _str(json['ImageName'] ?? json['imageName']),
        checklistLabelId:
            (json['ChecklistLabelId'] ?? json['checklistLabelId'] as num?)
                    ?.toInt() ??
                0,
      );
}

/// Maps to C#: Response<ResUploadImage>
/// { "status": bool, "message": string, "data": ResUploadImage }
class UploadFileResponse {
  final bool status;
  final String message;
  final UploadedFileModel? data;

  const UploadFileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['Data'];

    // data is a single ResUploadImage object (not a list)
    UploadedFileModel? parsed;
    if (raw is Map<String, dynamic>) {
      parsed = UploadedFileModel.fromJson(raw);
    }

    return UploadFileResponse(
      status: _parseBool(json['status'] ?? json['Status']),
      message: _str(json['message'] ?? json['Message']),
      data: parsed,
    );
  }
}
