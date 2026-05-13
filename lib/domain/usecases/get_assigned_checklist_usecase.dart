import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/checklist_entity.dart';
import '../repositories/checklist_repository.dart';
import '../../core/errors/failures.dart';

class GetAssignedChecklistUseCase {
  final ChecklistRepository repository;
  const GetAssignedChecklistUseCase(this.repository);

  Future<Either<Failure, List<ChecklistEntity>>> call(ChecklistParams params) {
    return repository.getAssignedChecklists(
      assignDateTime: params.assignDateTime,
      companyId: params.companyId,
      userId: params.userId,
    );
  }
}

class ChecklistParams extends Equatable {
  final String assignDateTime;
  final int companyId;
  final String userId;

  const ChecklistParams({
    required this.assignDateTime,
    required this.companyId,
    required this.userId,
  });

  @override
  List<Object> get props => [assignDateTime, companyId, userId];
}
