import 'package:dartz/dartz.dart';
import '../entities/checklist_entity.dart';
import '../../core/errors/failures.dart';

abstract class ChecklistRepository {
  Future<Either<Failure, List<ChecklistEntity>>> getAssignedChecklists({
    required String assignDateTime,
    required int companyId,
    required String userId,
  });
}
