import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class UploadFileRepository {
  Future<Either<Failure, String>> uploadFile({
    required int labelId,
    required String filePath,
    required String fileName,
    required String contentType,
  });
}
