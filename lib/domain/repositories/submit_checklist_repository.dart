import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/submit_checklist_model.dart';

abstract class SubmitChecklistRepository {
  Future<Either<Failure, SubmitChecklistData>> submit(
      SubmitChecklistRequest request);
}
