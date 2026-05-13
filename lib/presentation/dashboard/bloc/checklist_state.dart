part of 'checklist_bloc.dart';

abstract class ChecklistState extends Equatable {
  final DateTime selectedDate;
  const ChecklistState({required this.selectedDate});
  @override
  List<Object?> get props => [selectedDate];
}

class ChecklistInitial extends ChecklistState {
  ChecklistInitial() : super(selectedDate: DateTime.now());
}

class ChecklistLoading extends ChecklistState {
  const ChecklistLoading({required super.selectedDate});
}

class ChecklistLoaded extends ChecklistState {
  final List<ChecklistEntity> items;
  const ChecklistLoaded({required this.items, required super.selectedDate});

  @override
  List<Object?> get props => [items, selectedDate];
}

class ChecklistError extends ChecklistState {
  final String message;
  const ChecklistError({required this.message, required super.selectedDate});

  @override
  List<Object?> get props => [message, selectedDate];
}
