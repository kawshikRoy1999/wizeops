import '../../domain/entities/checklist_entity.dart';

class ChecklistRequestModel {
  final String assignDateTime;
  final int companyId;
  final String userId;

  const ChecklistRequestModel({
    required this.assignDateTime,
    required this.companyId,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'AssignDateTime': assignDateTime,
        'CompanyId': companyId,
        'UserId': userId,
      };
}

class ChecklistResponseModel {
  final bool status;
  final String message;
  final List<ChecklistItemModel> checkList;

  const ChecklistResponseModel({
    required this.status,
    required this.message,
    required this.checkList,
  });

  factory ChecklistResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final rawList = data?['checkList'] as List<dynamic>? ?? [];
    return ChecklistResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      checkList: rawList
          .map((e) => ChecklistItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChecklistItemModel {
  final int checklistAssignmentId;
  final int checklistId;
  final String checklistName;
  final String assignDateTime;
  final String checklistStatus;

  const ChecklistItemModel({
    required this.checklistAssignmentId,
    required this.checklistId,
    required this.checklistName,
    required this.assignDateTime,
    required this.checklistStatus,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      checklistAssignmentId: json['checklistAssignmentId'] as int? ?? 0,
      checklistId: json['checklistId'] as int? ?? 0,
      checklistName: json['checklistName'] as String? ?? '',
      assignDateTime: json['assignDateTime'] as String? ?? '',
      checklistStatus: json['checklistStatus'] as String? ?? '',
    );
  }

  ChecklistEntity toEntity() => ChecklistEntity(
        checklistAssignmentId: checklistAssignmentId,
        checklistId: checklistId,
        checklistName: checklistName,
        assignDateTime: assignDateTime,
        checklistStatus: checklistStatus,
      );
}
