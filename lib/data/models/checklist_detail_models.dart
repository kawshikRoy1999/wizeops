import '../../domain/entities/checklist_detail_entity.dart';

class ChecklistDetailRequestModel {
  final int checklistAssignmentId;
  final int companyId;
  final String assignDate;

  const ChecklistDetailRequestModel({
    required this.checklistAssignmentId,
    required this.companyId,
    required this.assignDate,
  });

  Map<String, dynamic> toJson() => {
        'ChecklistAssignmentId': checklistAssignmentId,
        'CompanyId': companyId,
        'AssignDate': assignDate,
      };
}

class ChecklistDetailResponseModel {
  final bool status;
  final String message;
  final ChecklistDetailDataModel? data;

  const ChecklistDetailResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory ChecklistDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as Map<String, dynamic>?;
    return ChecklistDetailResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: rawData != null ? ChecklistDetailDataModel.fromJson(rawData) : null,
    );
  }
}

class ChecklistDetailDataModel {
  final String checklistName;
  final String checklistStatus;
  final int checklistAssignmentId;
  final List<ChecklistDetailItemModel> checkListDetails;

  const ChecklistDetailDataModel({
    required this.checklistName,
    required this.checklistStatus,
    required this.checklistAssignmentId,
    required this.checkListDetails,
  });

  factory ChecklistDetailDataModel.fromJson(Map<String, dynamic> json) {
    final raw = json['checkListDetails'] as List<dynamic>? ?? [];
    return ChecklistDetailDataModel(
      checklistName: json['checklistName'] as String? ?? '',
      checklistStatus: json['checklistStatus'] as String? ?? '',
      checklistAssignmentId: json['checklistAssignmentId'] as int? ?? 0,
      checkListDetails: raw
          .map((e) =>
              ChecklistDetailItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ChecklistDetailSummary toEntity() => ChecklistDetailSummary(
        checklistName: checklistName,
        checklistStatus: checklistStatus,
        checklistAssignmentId: checklistAssignmentId,
        details: checkListDetails.map((e) => e.toEntity()).toList(),
      );
}

class ChecklistDetailItemModel {
  final int parentChecklistLabelId;
  final int parentChecklistId;
  final String parentLabelName;
  final String checklistDesc;
  final String checklistValue;
  final String optionText;
  final String customFieldTypeName;
  final String checklistStatus;
  final String checklistNote;
  final int checkListAssignmentValuesId;
  final bool status;
  final String filePathsJson;

  const ChecklistDetailItemModel({
    required this.parentChecklistLabelId,
    required this.parentChecklistId,
    required this.parentLabelName,
    required this.checklistDesc,
    required this.checklistValue,
    required this.optionText,
    required this.customFieldTypeName,
    required this.checklistStatus,
    required this.checklistNote,
    required this.checkListAssignmentValuesId,
    required this.status,
    required this.filePathsJson,
  });

  factory ChecklistDetailItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistDetailItemModel(
      parentChecklistLabelId: json['parentChecklistLabelId'] as int? ?? 0,
      parentChecklistId: json['parentChecklistId'] as int? ?? 0,
      parentLabelName: json['parentLabelName'] as String? ?? '',
      checklistDesc: json['checklistDesc'] as String? ?? '',
      checklistValue: json['checklistValue'] as String? ?? '',
      optionText: json['optionText'] as String? ?? '',
      customFieldTypeName: json['customFieldTypeName'] as String? ?? '',
      checklistStatus: json['checklistStatus'] as String? ?? '',
      checklistNote: json['checklistNote'] as String? ?? '',
      checkListAssignmentValuesId:
          json['checkListAssignmentValuesId'] as int? ?? 0,
      status: json['status'] as bool? ?? false,
      filePathsJson: json['filePathsJson'] as String? ?? '',
    );
  }

  ChecklistDetailEntity toEntity() => ChecklistDetailEntity(
        parentChecklistLabelId: parentChecklistLabelId,
        parentChecklistId: parentChecklistId,
        parentLabelName: parentLabelName,
        checklistDesc: checklistDesc,
        checklistValue: checklistValue,
        optionText: optionText,
        customFieldTypeName: customFieldTypeName,
        checklistStatus: checklistStatus,
        checklistNote: checklistNote,
        checkListAssignmentValuesId: checkListAssignmentValuesId,
        status: status,
        filePathsJson: filePathsJson,
      );
}
