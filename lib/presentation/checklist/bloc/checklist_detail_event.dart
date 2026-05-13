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

class UpdateNoteValue extends ChecklistDetailEvent {
  final int labelId;
  final String value;

  const UpdateNoteValue({required this.labelId, required this.value});

  @override
  List<Object> get props => [labelId, value];
}

class UpdateFlagValue extends ChecklistDetailEvent {
  final int labelId;
  final bool raised;

  const UpdateFlagValue({required this.labelId, required this.raised});

  @override
  List<Object> get props => [labelId, raised];
}

class UpdateFileValue extends ChecklistDetailEvent {
  final int labelId;
  final List<String> paths;

  const UpdateFileValue({required this.labelId, required this.paths});

  @override
  List<Object> get props => [labelId, paths];
}
