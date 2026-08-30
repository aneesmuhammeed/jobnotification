import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';

/// Application data model — maps between Supabase JSON and domain entity.
class ApplicationModel extends ApplicationEntity {
  const ApplicationModel({
    required super.id,
    required super.userId,
    required super.jobId,
    required super.appliedAt,
    super.documentPath,
    super.documentName,
    super.companyName,
    super.jobTitle,
  });

  /// Create from Supabase JSON response.
  /// Supports joined job data (when selecting with `jobs(...)` join).
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Handle joined job data
    final jobData = json['jobs'] as Map<String, dynamic>?;

    return ApplicationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      jobId: json['job_id'] as String,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      documentPath: json['document_path'] as String?,
      documentName: json['document_name'] as String?,
      companyName: jobData?['company_name'] as String?,
      jobTitle: jobData?['job_title'] as String?,
    );
  }

  /// Convert to JSON for Supabase insert.
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'job_id': jobId,
      'document_path': documentPath,
      'document_name': documentName,
    };
  }
}
