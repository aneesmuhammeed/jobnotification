import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';

/// Job data model — maps between Supabase JSON and domain entity.
class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.companyName,
    required super.jobTitle,
    required super.description,
    required super.applicationUrls,
    required super.lastDate,
    required super.createdAt,
    required super.createdBy,
    required super.isActive,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      companyName: json['company_name'] as String,
      jobTitle: json['job_title'] as String,
      description: json['description'] as String,
      applicationUrls: (json['application_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lastDate: DateTime.parse(json['last_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'job_title': jobTitle,
      'description': description,
      'application_urls': applicationUrls,
      'application_url': applicationUrls.isNotEmpty ? applicationUrls.first : '',
      'last_date': lastDate.toIso8601String().split('T').first,
      'created_by': createdBy,
      'is_active': isActive,
    };
  }

  /// Create a new JobModel for insertion (without id and createdAt).
  Map<String, dynamic> toInsertJson() {
    return {
      'company_name': companyName,
      'job_title': jobTitle,
      'description': description,
      'application_urls': applicationUrls,
      'application_url': applicationUrls.isNotEmpty ? applicationUrls.first : '',
      'last_date': lastDate.toIso8601String().split('T').first,
      'created_by': createdBy,
      'is_active': isActive,
    };
  }
}
