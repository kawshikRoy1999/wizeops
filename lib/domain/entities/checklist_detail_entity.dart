import 'package:equatable/equatable.dart';

class ChecklistDetailEntity extends Equatable {
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

  const ChecklistDetailEntity({
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

  List<String> get options => optionText.isNotEmpty
      ? optionText.split(',').map((e) => e.trim()).toList()
      : [];

  FieldType get fieldType {
    switch (customFieldTypeName.toLowerCase()) {
      case 'radio button':
        return FieldType.radio;
      case 'dropdown':
        return FieldType.dropdown;
      case 'checkbox':
        return FieldType.checkbox;
      default:
        return FieldType.textBox;
    }
  }

  @override
  List<Object?> get props => [parentChecklistLabelId, checklistValue, status, filePathsJson];
}

enum FieldType { radio, dropdown, checkbox, textBox }

class ChecklistDetailSummary extends Equatable {
  final String checklistName;
  final String checklistStatus;
  final int checklistAssignmentId;
  final List<ChecklistDetailEntity> details;

  const ChecklistDetailSummary({
    required this.checklistName,
    required this.checklistStatus,
    required this.checklistAssignmentId,
    required this.details,
  });

  bool get isSubmitted => checklistStatus.toLowerCase() == 'submit';

  @override
  List<Object?> get props => [checklistAssignmentId];
}
