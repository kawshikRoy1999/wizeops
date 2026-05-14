import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/errors/failures.dart';
import '../../data/models/submit_checklist_model.dart';
import '../../domain/repositories/submit_checklist_repository.dart';
import '../datasources/submit_checklist_datasource.dart';

class SubmitChecklistRepositoryImpl implements SubmitChecklistRepository {
  final SubmitChecklistDataSource dataSource;
  SubmitChecklistRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, SubmitChecklistData>> submit(
      SubmitChecklistRequest request) async {
    try {
      final result = await dataSource.submit(request);
      if (!result.status) {
        return Left(ServerFailure(
            result.message.isNotEmpty ? result.message : 'Submit failed'));
      }
      return Right(result.data ??
          SubmitChecklistData(
            checkListAssignmentValuesId: 0,
            response: '',
            checkListStatus: request.checkListStatus,
            checklistAssignmentId: request.checklistAssignmentId,
          ));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Submit failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
