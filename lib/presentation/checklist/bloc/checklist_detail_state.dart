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
  final Map<int, String> noteValues;
  final Map<int, bool> flagValues;
  final Map<int, List<String>> fileValues;

  const ChecklistDetailLoaded({
    required this.summary,
    required this.fieldValues,
    required this.noteValues,
    required this.flagValues,
    required this.fileValues,
  });

  ChecklistDetailLoaded copyWith({
    ChecklistDetailSummary? summary,
    Map<int, String>? fieldValues,
    Map<int, String>? noteValues,
    Map<int, bool>? flagValues,
    Map<int, List<String>>? fileValues,
  }) =>
      ChecklistDetailLoaded(
        summary: summary ?? this.summary,
        fieldValues: fieldValues ?? this.fieldValues,
        noteValues: noteValues ?? this.noteValues,
        flagValues: flagValues ?? this.flagValues,
        fileValues: fileValues ?? this.fileValues,
      );

  @override
  List<Object?> get props => [summary, fieldValues, noteValues, flagValues, fileValues];
}

class ChecklistDetailError extends ChecklistDetailState {
  final String message;
  const ChecklistDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
