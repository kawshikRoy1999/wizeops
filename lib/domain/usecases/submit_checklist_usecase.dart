import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/submit_checklist_model.dart';
import '../repositories/submit_checklist_repository.dart';

class SubmitChecklistUseCase {
  final SubmitChecklistRepository repository;
  SubmitChecklistUseCase(this.repository);

  Future<Either<Failure, SubmitChecklistData>> call(
          SubmitChecklistRequest request) =>
      repository.submit(request);
}
