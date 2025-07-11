import 'package:collection/collection.dart';
import 'lesson.dart';

enum ActivityType {
  LISTENING_DICTATION,
  LISTENING_COMPREHENSION,
  SPEAKING_REPETITION,
  SPEAKING_ROLEPLAY,
  WRITING_ESSAY,
  WRITING_PARAGRAPH,
  VOCABULARY_MATCHING,
  GRAMMAR_FILL_IN_BLANK,
  READING_MATERIAL,
}

enum Status {
  NOT_STARTED,
  IN_PROGRESS,
  COMPLETED,
}

ActivityType? activityTypeFromString(String? type) {
  if (type == null) return null;
  return ActivityType.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == type.toUpperCase(),
  );
}

Status? statusFromString(String? status) {
  if (status == null) return null;
  return Status.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == status.toUpperCase(),
  );
}

class ProgressRequest {
  final int userId;
  final int lessonId;
  final ActivityType activityType;
  final Status status;
  final int completionPercentage;

  ProgressRequest({
    required this.userId,
    required this.lessonId,
    required this.activityType,
    required this.status,
    required this.completionPercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'activityType': activityType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'completionPercentage': completionPercentage,
    };
  }
}

class ProgressResponse {
  final int? progressId;
  final int? userId;
  final int? lessonId;
  final ActivityType? activityType;
  final Status? status;
  final int? completionPercentage;
  final DateTime? lastUpdated;

  ProgressResponse({
    this.progressId,
    this.userId,
    this.lessonId,
    this.activityType,
    this.status,
    this.completionPercentage,
    this.lastUpdated,
  });

  factory ProgressResponse.fromJson(Map<String, dynamic> json) {
    return ProgressResponse(
      progressId: json['progressId'] as int?,
      userId: json['userId'] as int?,
      lessonId: json['lessonId'] as int?,
      activityType: activityTypeFromString(json['activityType'] as String?),
      status: statusFromString(json['status'] as String?),
      completionPercentage: json['completionPercentage'] as int?,
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progressId': progressId,
      'userId': userId,
      'lessonId': lessonId,
      'activityType': activityType?.toString().split('.').last,
      'status': status?.toString().split('.').last,
      'completionPercentage': completionPercentage,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  bool get isError => progressId == null && userId == null;
}

class ProgressSearchRequest {
  final int? userId;
  final int? lessonId;
  final ActivityType? activityType;
  final Status? status;
  final int? minCompletionPercentage;
  final int? maxCompletionPercentage;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  ProgressSearchRequest({
    this.userId,
    this.lessonId,
    this.activityType,
    this.status,
    this.minCompletionPercentage,
    this.maxCompletionPercentage,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = page != null && page >= 0 ? page : 0,
        size = size != null && size > 0 ? size : 10,
        sortBy = sortBy != null &&
            ['progressId', 'userId', 'lessonId', 'activityType', 'status', 'completionPercentage', 'lastUpdated']
                .contains(sortBy)
            ? sortBy
            : 'progressId',
        sortDir = sortDir != null && ['ASC', 'DESC'].contains(sortDir.toUpperCase()) ? sortDir : 'ASC';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    if (userId != null) json['userId'] = userId;
    if (lessonId != null) json['lessonId'] = lessonId;
    if (activityType != null) json['activityType'] = activityType.toString().split('.').last;
    if (status != null) json['status'] = status.toString().split('.').last;
    if (minCompletionPercentage != null) json['minCompletionPercentage'] = minCompletionPercentage;
    if (maxCompletionPercentage != null) json['maxCompletionPercentage'] = maxCompletionPercentage;
    return json;
  }
}

class ProgressPageResponse {
  final List<ProgressResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  ProgressPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory ProgressPageResponse.fromJson(Map<String, dynamic> json) {
    return ProgressPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => ProgressResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['currentPage'] as int,
      size: json['pageSize'] as int,
    );
  }
}