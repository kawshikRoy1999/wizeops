part of 'checklist_detail_bloc.dart';

abstract class ChecklistDetailState extends Equatable {
  const ChecklistDetailState();
  @override
  List<Object?> get props => [];
}

class ChecklistDetailInitial extends ChecklistDetailState {
  const ChecklistDetailInitial();
}

class ChecklistDetailLoading extends ChecklistDetailState {
  const ChecklistDetailLoading();
}

class ChecklistDetailLoaded extends ChecklistDetailState {
  final ChecklistDetailSummary summary;
  final Map<int, String> fieldValues;

  const ChecklistDetailLoaded({
    required this.summary,
    required this.fieldValues,
  });

  ChecklistDetailLoaded copyWith({
    ChecklistDetailSummary? summary,
    Map<int, String>? fieldValues,
  }) =>
      ChecklistDetailLoaded(
        summary: summary ?? this.summary,
        fieldValues: fieldValues ?? this.fieldValues,
      );

  @override
  List<Object?> get props => [summary, fieldValues];
}

class ChecklistDetailError extends ChecklistDetailState {
  final String message;
  const ChecklistDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
