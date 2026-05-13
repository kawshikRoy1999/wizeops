part of 'checklist_detail_bloc.dart';

abstract class ChecklistDetailEvent extends Equatable {
  const ChecklistDetailEvent();
  @override
  List<Object> get props => [];
}

class LoadChecklistDetails extends ChecklistDetailEvent {
  final int checklistAssignmentId;
  final int companyId;
  final String assignDate;

  const LoadChecklistDetails({
    required this.checklistAssignmentId,
    required this.companyId,
    required this.assignDate,
  });

  @override
  List<Object> get props => [checklistAssignmentId, companyId, assignDate];
}

class UpdateFieldValue extends ChecklistDetailEvent {
  final int labelId;
  final String value;

  const UpdateFieldValue({required this.labelId, required this.value});

  @override
  List<Object> get props => [labelId, value];
}
