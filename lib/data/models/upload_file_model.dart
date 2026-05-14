String _str(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

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

class UploadFileResponse {
  final bool status;
  final String message;
  final List<UploadedFileModel> data;

  const UploadFileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    // 'data' may be a List or a single object — handle both
    final raw = json['data'] ?? json['Data'];
    final List<dynamic> rawList =
        raw is List ? raw : (raw != null ? [raw] : []);

    return UploadFileResponse(
      status: (json['status'] ?? json['Status']) as bool? ?? false,
      message: _str(json['message'] ?? json['Message']),
      data: rawList
          .map((e) => UploadedFileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
