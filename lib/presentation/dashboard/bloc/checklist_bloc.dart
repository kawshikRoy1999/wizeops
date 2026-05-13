import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/checklist_entity.dart';
import '../../../domain/usecases/get_assigned_checklist_usecase.dart';

part 'checklist_event.dart';
part 'checklist_state.dart';

class ChecklistBloc extends Bloc<ChecklistEvent, ChecklistState> {
  final GetAssignedChecklistUseCase useCase;

  ChecklistBloc({required this.useCase}) : super(ChecklistInitial()) {
    on<FetchChecklists>(_onFetch);
  }

  Future<void> _onFetch(
      FetchChecklists event, Emitter<ChecklistState> emit) async {
    emit(ChecklistLoading(selectedDate: event.selectedDate));
    final result = await useCase(ChecklistParams(
      assignDateTime: event.assignDateTime,
      companyId: event.companyId,
      userId: event.userId,
    ));
    result.fold(
      (failure) => emit(ChecklistError(
          message: failure.message, selectedDate: event.selectedDate)),
      (list) => emit(ChecklistLoaded(
          items: list, selectedDate: event.selectedDate)),
    );
  }
}
