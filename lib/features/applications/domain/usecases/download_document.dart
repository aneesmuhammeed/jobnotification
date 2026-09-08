import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/features/applications/domain/repositories/application_repository.dart';

class DownloadDocument {
  final ApplicationRepository repository;

  DownloadDocument(this.repository);

  Future<Either<Failure, String>> call(DownloadDocumentParams params) {
    return repository.downloadDocument(params.fileId, params.documentName);
  }
}

class DownloadDocumentParams {
  final String fileId;
  final String documentName;

  DownloadDocumentParams({
    required this.fileId,
    required this.documentName,
  });
}
