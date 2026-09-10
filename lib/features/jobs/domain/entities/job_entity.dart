import 'package:equatable/equatable.dart';

/// Job entity — domain layer representation of a job posting.
class JobEntity extends Equatable {
  final String id;
  final String companyName;
  final String jobTitle;
  final String description;
  final List<String> applicationUrls;
  final DateTime lastDate;
  final DateTime createdAt;
  final String createdBy;
  final bool isActive;

  const JobEntity({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.description,
    required this.applicationUrls,
    required this.lastDate,
    required this.createdAt,
    required this.createdBy,
    required this.isActive,
  });

  /// Whether this job's deadline has passed.
  bool get isExpired {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
    return lastDateOnly.isBefore(todayDateOnly);
  }

  /// Whether this job is available (active and not expired).
  bool get isAvailable => isActive && !isExpired;

  @override
  List<Object?> get props => [
        id, companyName, jobTitle, description, applicationUrls,
        lastDate, createdAt, createdBy, isActive,
      ];
}
