import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/upload_file_repository.dart';
import '../datasources/upload_file_datasource.dart';

class UploadFileRepositoryImpl implements UploadFileRepository {
  final UploadFileDataSource dataSource;
  UploadFileRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, String>> uploadFile({
    required int labelId,
    required String filePath,
    required String fileName,
    required String contentType,
    required int companyId,
    required String imageFilePath,
  }) async {
    try {
      final result = await dataSource.uploadFile(
        labelId: labelId,
        filePath: filePath,
        fileName: fileName,
        contentType: contentType,
        companyId: companyId,
        imageFilePath: imageFilePath,
      );
      return Right(result.imagePath);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Upload failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
