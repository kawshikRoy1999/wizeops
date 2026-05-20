/// ─── Request ────────────────────────────────────────────────────────────────
library;

class FilePathRequest {
  final int mapId;
  final String imagePath;
  final String imageName;
  final int checklistLabelId;

  const FilePathRequest({
    required this.mapId,
    required this.imagePath,
    required this.imageName,
    required this.checklistLabelId,
  });

  Map<String, dynamic> toJson() => {
        'MapId': mapId,
        'ImagePath': imagePath,
        'ImageName': imageName,
        'ChecklistLabelId': checklistLabelId,
      };
}

class AssignCheckListItem {
  final int checkListAssignmentValuesId;
  final int checklistLabelId;
  final String checklistValue;
  final String checklistNote;
  final bool flagRaised;
  final List<FilePathRequest> filePaths;

  const AssignCheckListItem({
    required this.checkListAssignmentValuesId,
    required this.checklistLabelId,
    required this.checklistValue,
    required this.checklistNote,
    required this.flagRaised,
    required this.filePaths,
  });

  Map<String, dynamic> toJson() => {
        'CheckListAssignmentValuesId': checkListAssignmentValuesId,
        'ChecklistLabelId': checklistLabelId,
        'ChecklistValue': checklistValue,
        'ChecklistNote': checklistNote,
        'FlagRaised': flagRaised,
        'FilePaths': filePaths.map((f) => f.toJson()).toList(),
      };
}

class SubmitChecklistRequest {
  final int checkListAssignmentValuesId;
  final int checklistAssignmentId;
  final String checkListStatus; // "Save" or "Completed"
  final String createdBy; // user GUID
  final List<AssignCheckListItem> assignCheckList;

  const SubmitChecklistRequest({
    required this.checkListAssignmentValuesId,
    required this.checklistAssignmentId,
    required this.checkListStatus,
    required this.createdBy,
    required this.assignCheckList,
  });

  Map<String, dynamic> toJson() => {
        'CheckListAssignmentValuesId': checkListAssignmentValuesId,
        'ChecklistAssignmentId': checklistAssignmentId,
        'CheckListStatus': checkListStatus,
        'CreatedBy': createdBy,
        'AssignCheckList': assignCheckList.map((e) => e.toJson()).toList(),
      };
}

/// ─── Response ───────────────────────────────────────────────────────────────

class SubmitChecklistResponse {
  final bool status;
  final String message;
  final SubmitChecklistData? data;

  const SubmitChecklistResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SubmitChecklistResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['Data'];
    return SubmitChecklistResponse(
      status: _parseBool(json['status'] ?? json['Status']),
      message: _str(json['message'] ?? json['Message']),
      data: raw is Map<String, dynamic>
          ? SubmitChecklistData.fromJson(raw)
          : null,
    );
  }
}

class SubmitChecklistData {
  final int checkListAssignmentValuesId;
  final String response;
  final String checkListStatus;
  final int checklistAssignmentId;

  const SubmitChecklistData({
    required this.checkListAssignmentValuesId,
    required this.response,
    required this.checkListStatus,
    required this.checklistAssignmentId,
  });

  factory SubmitChecklistData.fromJson(Map<String, dynamic> json) =>
      SubmitChecklistData(
        checkListAssignmentValuesId:
            (json['CheckListAssignmentValuesId'] ?? json['checkListAssignmentValuesId'] as num?)
                    ?.toInt() ??
                0,
        response: _str(json['Response'] ?? json['response']),
        checkListStatus:
            _str(json['CheckListStatus'] ?? json['checkListStatus']),
        checklistAssignmentId:
            (json['ChecklistAssignmentId'] ?? json['checklistAssignmentId'] as num?)
                    ?.toInt() ??
                0,
      );
}

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
