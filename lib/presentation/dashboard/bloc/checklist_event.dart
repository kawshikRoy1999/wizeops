part of 'checklist_bloc.dart';

abstract class ChecklistEvent extends Equatable {
  const ChecklistEvent();
  @override
  List<Object> get props => [];
}

class FetchChecklists extends ChecklistEvent {
  final String assignDateTime;
  final int companyId;
  final String userId;
  final DateTime selectedDate;

  const FetchChecklists({
    required this.assignDateTime,
    required this.companyId,
    required this.userId,
    required this.selectedDate,
  });

  @override
  List<Object> get props => [assignDateTime, companyId, userId];
}
