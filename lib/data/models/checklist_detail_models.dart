import 'dart:convert';
import '../../domain/entities/checklist_detail_entity.dart';

/// Safe string coercion — handles String, num, bool, List, Map, null.
/// Lists/Maps are JSON-encoded so callers can decode them if needed.
String _str(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is List || v is Map) return jsonEncode(v);
  return v.toString();
}

/// Safe bool coercion — handles bool, int (1/0), String ("true"/"1"), null.
bool _parseBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

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
    // 'data' may be a Map, a List, or null depending on the API version
    final raw = json['data'];
    final Map<String, dynamic>? rawData = raw is Map<String, dynamic>
        ? raw
        : (raw is List && raw.isNotEmpty && raw.first is Map)
            ? raw.first as Map<String, dynamic>
            : null;

    return ChecklistDetailResponseModel(
      // status may come as bool true/false OR int 1/0
      status: _parseBool(json['status']),
      message: _str(json['message']),
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
    final rawItems = json['checkListDetails'];
    final raw = rawItems is List ? rawItems : <dynamic>[];
    return ChecklistDetailDataModel(
      checklistName: _str(json['checklistName']),
      checklistStatus: _str(json['checklistStatus']),
      checklistAssignmentId:
          (json['checklistAssignmentId'] as num?)?.toInt() ?? 0,
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
  final bool flagRaised;
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
    required this.flagRaised,
    required this.filePathsJson,
  });

  factory ChecklistDetailItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistDetailItemModel(
      parentChecklistLabelId:
          (json['parentChecklistLabelId'] as num?)?.toInt() ?? 0,
      parentChecklistId:
          (json['parentChecklistId'] as num?)?.toInt() ?? 0,
      parentLabelName: _str(json['parentLabelName']),
      checklistDesc: _str(json['checklistDesc']),
      checklistValue: _str(json['checklistValue']),
      optionText: _str(json['optionText']),
      customFieldTypeName: _str(json['customFieldTypeName']),
      checklistStatus: _str(json['checklistStatus']),
      checklistNote: _str(json['checklistNote']),
      checkListAssignmentValuesId:
          (json['checkListAssignmentValuesId'] as num?)?.toInt() ?? 0,
      flagRaised: _parseBool(json['flagRaised']),
      // filePathsJson may arrive as a String, a List, or null
      filePathsJson: _str(json['filePathsJson']),
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
        flagRaised: flagRaised,
        filePathsJson: filePathsJson,
      );
}
