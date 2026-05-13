import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/checklist_detail_entity.dart';
import '../../../domain/usecases/get_checklist_details_usecase.dart';

part 'checklist_detail_event.dart';
part 'checklist_detail_state.dart';

class ChecklistDetailBloc
    extends Bloc<ChecklistDetailEvent, ChecklistDetailState> {
  final GetChecklistDetailsUseCase useCase;

  ChecklistDetailBloc({required this.useCase})
      : super(const ChecklistDetailInitial()) {
    on<LoadChecklistDetails>(_onLoad);
    on<UpdateFieldValue>(_onUpdateField);
    on<UpdateNoteValue>(_onUpdateNote);
    on<UpdateFlagValue>(_onUpdateFlag);
    on<UpdateFileValue>(_onUpdateFile);
  }

  Future<void> _onLoad(
      LoadChecklistDetails event, Emitter<ChecklistDetailState> emit) async {
    emit(const ChecklistDetailLoading());
    final result = await useCase(ChecklistDetailParams(
      checklistAssignmentId: event.checklistAssignmentId,
      companyId: event.companyId,
      assignDate: event.assignDate,
    ));
    result.fold(
      (failure) => emit(ChecklistDetailError(message: failure.message)),
      (summary) => emit(ChecklistDetailLoaded(
        summary: summary,
        fieldValues: {
          for (final d in summary.details)
            d.parentChecklistLabelId: d.checklistValue,
        },
        noteValues: {
          for (final d in summary.details)
            d.parentChecklistLabelId: d.checklistNote,
        },
        flagValues: {
          for (final d in summary.details)
            d.parentChecklistLabelId: d.status,
        },
        fileValues: {
          for (final d in summary.details)
            d.parentChecklistLabelId: _parsePaths(d.filePathsJson),
        },
      )),
    );
  }

  List<String> _parsePaths(String json) {
    if (json.isEmpty) return [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return decoded.cast<String>();
    } catch (_) {}
    return [];
  }

  void _onUpdateField(
      UpdateFieldValue event, Emitter<ChecklistDetailState> emit) {
    final current = state;
    if (current is ChecklistDetailLoaded) {
      final updated = Map<int, String>.from(current.fieldValues);
      updated[event.labelId] = event.value;
      emit(current.copyWith(fieldValues: updated));
    }
  }

  void _onUpdateNote(
      UpdateNoteValue event, Emitter<ChecklistDetailState> emit) {
    final current = state;
    if (current is ChecklistDetailLoaded) {
      final updated = Map<int, String>.from(current.noteValues);
      updated[event.labelId] = event.value;
      emit(current.copyWith(noteValues: updated));
    }
  }

  void _onUpdateFlag(
      UpdateFlagValue event, Emitter<ChecklistDetailState> emit) {
    final current = state;
    if (current is ChecklistDetailLoaded) {
      final updated = Map<int, bool>.from(current.flagValues);
      updated[event.labelId] = event.raised;
      emit(current.copyWith(flagValues: updated));
    }
  }

  void _onUpdateFile(
      UpdateFileValue event, Emitter<ChecklistDetailState> emit) {
    final current = state;
    if (current is ChecklistDetailLoaded) {
      final updated = Map<int, List<String>>.from(current.fileValues);
      updated[event.labelId] = event.paths;
      emit(current.copyWith(fileValues: updated));
    }
  }
}
