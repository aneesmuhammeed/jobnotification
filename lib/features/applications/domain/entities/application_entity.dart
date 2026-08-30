import 'package:equatable/equatable.dart';

/// Application entity — domain layer representation of a user's job application record.
class ApplicationEntity extends Equatable {
  final String id;
  final String userId;
  final String jobId;
  final DateTime appliedAt;
  final String? documentPath;
  final String? documentName;

  // Optional: joined job data for display purposes
  final String? companyName;
  final String? jobTitle;

  const ApplicationEntity({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.appliedAt,
    this.documentPath,
    this.documentName,
    this.companyName,
    this.jobTitle,
  });

  bool get hasDocument => documentPath != null && documentPath!.isNotEmpty;

  @override
  List<Object?> get props => [
        id, userId, jobId, appliedAt,
        documentPath, documentName,
        companyName, jobTitle,
      ];
}
