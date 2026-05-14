import 'package:equatable/equatable.dart';

class ChecklistEntity extends Equatable {
  final int checklistAssignmentId;
  final int checklistId;
  final String checklistName;
  final String assignDateTime;
  final String checklistStatus;

  const ChecklistEntity({
    required this.checklistAssignmentId,
    required this.checklistId,
    required this.checklistName,
    required this.assignDateTime,
    required this.checklistStatus,
  });

  bool get isSubmitted =>
      checklistStatus.toLowerCase().startsWith('submit');

  @override
  List<Object?> get props => [checklistAssignmentId, checklistId, checklistStatus];
}
