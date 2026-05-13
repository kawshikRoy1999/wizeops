import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/checklist_detail_entity.dart';
import '../../domain/repositories/checklist_detail_repository.dart';
import '../datasources/checklist_detail_remote_datasource.dart';
import '../models/checklist_detail_models.dart';

class ChecklistDetailRepositoryImpl implements ChecklistDetailRepository {
  final ChecklistDetailRemoteDataSource remoteDataSource;
  const ChecklistDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChecklistDetailSummary>> getChecklistDetails({
    required int checklistAssignmentId,
    required int companyId,
    required String assignDate,
  }) async {
    try {
      final result = await remoteDataSource.getChecklistDetails(
        ChecklistDetailRequestModel(
          checklistAssignmentId: checklistAssignmentId,
          companyId: companyId,
          assignDate: assignDate,
        ),
      );
      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
