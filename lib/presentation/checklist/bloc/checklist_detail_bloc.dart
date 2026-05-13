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
      )),
    );
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
}
