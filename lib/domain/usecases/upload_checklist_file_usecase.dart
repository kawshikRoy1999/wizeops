import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/upload_file_repository.dart';

class UploadChecklistFileParams {
  final int labelId;
  final String filePath;
  final String fileName;
  final String contentType;

  const UploadChecklistFileParams({
    required this.labelId,
    required this.filePath,
    required this.fileName,
    required this.contentType,
  });
}

class UploadChecklistFileUseCase {
  final UploadFileRepository repository;
  UploadChecklistFileUseCase(this.repository);

  Future<Either<Failure, String>> call(UploadChecklistFileParams params) =>
      repository.uploadFile(
        labelId: params.labelId,
        filePath: params.filePath,
        fileName: params.fileName,
        contentType: params.contentType,
      );
}
