import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/checklist_detail_entity.dart';
import '../repositories/checklist_detail_repository.dart';
import '../../core/errors/failures.dart';

class GetChecklistDetailsUseCase {
  final ChecklistDetailRepository repository;
  const GetChecklistDetailsUseCase(this.repository);

  Future<Either<Failure, ChecklistDetailSummary>> call(
      ChecklistDetailParams params) {
    return repository.getChecklistDetails(
      checklistAssignmentId: params.checklistAssignmentId,
      companyId: params.companyId,
      assignDate: params.assignDate,
    );
  }
}

class ChecklistDetailParams extends Equatable {
  final int checklistAssignmentId;
  final int companyId;
  final String assignDate;

  const ChecklistDetailParams({
    required this.checklistAssignmentId,
    required this.companyId,
    required this.assignDate,
  });

  @override
  List<Object> get props => [checklistAssignmentId, companyId, assignDate];
}
