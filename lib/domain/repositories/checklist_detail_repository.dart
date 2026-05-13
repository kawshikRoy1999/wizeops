import 'package:dartz/dartz.dart';
import '../entities/checklist_detail_entity.dart';
import '../../core/errors/failures.dart';

abstract class ChecklistDetailRepository {
  Future<Either<Failure, ChecklistDetailSummary>> getChecklistDetails({
    required int checklistAssignmentId,
    required int companyId,
    required String assignDate,
  });
}
