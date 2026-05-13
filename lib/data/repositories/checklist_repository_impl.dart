import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/checklist_entity.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../datasources/checklist_remote_datasource.dart';
import '../models/checklist_models.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final ChecklistRemoteDataSource remoteDataSource;
  const ChecklistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ChecklistEntity>>> getAssignedChecklists({
    required String assignDateTime,
    required int companyId,
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.getAssignedChecklists(
        ChecklistRequestModel(
          assignDateTime: assignDateTime,
          companyId: companyId,
          userId: userId,
        ),
      );
      return Right(result.checkList.map((e) => e.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
