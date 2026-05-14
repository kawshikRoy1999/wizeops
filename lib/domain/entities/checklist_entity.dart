import 'package:equatable/equatable.dart';

class ChecklistEntity extends Equatable {
  final int checklistAssignmentId;
  final int checklistId;
  final String checklistName;
  final String assignDateTime;
  final String checklistStatus;
  final int totalFilledCount;
  final int totalCount;

  const ChecklistEntity({
    required this.checklistAssignmentId,
    required this.checklistId,
    required this.checklistName,
    required this.assignDateTime,
    required this.checklistStatus,
    this.totalFilledCount = 0,
    this.totalCount = 0,
  });

  bool get isSubmitted =>
      checklistStatus.toLowerCase() == 'completed';

  double get progressRatio =>
      totalCount > 0 ? (totalFilledCount / totalCount).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [checklistAssignmentId, checklistId, checklistStatus, totalFilledCount, totalCount];
}
