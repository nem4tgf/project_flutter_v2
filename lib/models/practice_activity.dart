import 'package:collection/collection.dart';
import 'lesson.dart';

enum ActivitySkill {
  LISTENING,
  SPEAKING,
  READING,
  WRITING,
  VOCABULARY,
  GRAMMAR,
}

enum ActivityType {
  LISTENING_DICTATION,
  LISTENING_COMPREHENSION,
  SPEAKING_REPETITION,
  SPEAKING_ROLEPLAY,
  WRITING_ESSAY,
  WRITING_PARAGRAPH,
  VOCABULARY_MATCHING,
  GRAMMAR_FILL_IN_BLANK,
  READING_COMPREHENSION,
}

ActivitySkill? activitySkillFromString(String? skill) {
  if (skill == null) return null;
  return ActivitySkill.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == skill.toUpperCase(),
  );
}

ActivityType? activityTypeFromString(String? type) {
  if (type == null) return null;
  return ActivityType.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == type.toUpperCase(),
  );
}

class PracticeActivityRequest {
  final int lessonId;
  final String title;
  final String description;
  final ActivitySkill skill;
  final ActivityType activityType;
  final String? materialUrl;
  final String? transcriptText;
  final String? promptText;
  final String? expectedOutputText;

  PracticeActivityRequest({
    required this.lessonId,
    required this.title,
    required this.description,
    required this.skill,
    required this.activityType,
    this.materialUrl,
    this.transcriptText,
    this.promptText,
    this.expectedOutputText,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'skill': skill.toString().split('.').last,
      'activityType': activityType.toString().split('.').last,
      'materialUrl': materialUrl,
      'transcriptText': transcriptText,
      'promptText': promptText,
      'expectedOutputText': expectedOutputText,
    };
  }
}

class PracticeActivityResponse {
  final int? activityId;
  final int? lessonId;
  final String? title;
  final String? description;
  final ActivitySkill? skill;
  final ActivityType? activityType;
  final String? materialUrl;
  final String? transcriptText;
  final String? promptText;
  final String? expectedOutputText;
  final DateTime? createdAt;

  PracticeActivityResponse({
    this.activityId,
    this.lessonId,
    this.title,
    this.description,
    this.skill,
    this.activityType,
    this.materialUrl,
    this.transcriptText,
    this.promptText,
    this.expectedOutputText,
    this.createdAt,
  });

  factory PracticeActivityResponse.fromJson(Map<String, dynamic> json) {
    return PracticeActivityResponse(
      activityId: json['activityId'] as int?,
      lessonId: json['lessonId'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      skill: activitySkillFromString(json['skill'] as String?),
      activityType: activityTypeFromString(json['activityType'] as String?),
      materialUrl: json['materialUrl'] as String?,
      transcriptText: json['transcriptText'] as String?,
      promptText: json['promptText'] as String?,
      expectedOutputText: json['expectedOutputText'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'skill': skill?.toString().split('.').last,
      'activityType': activityType?.toString().split('.').last,
      'materialUrl': materialUrl,
      'transcriptText': transcriptText,
      'promptText': promptText,
      'expectedOutputText': expectedOutputText,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isError => activityId == null;
}

class PracticeActivityPageResponse {
  final List<PracticeActivityResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  PracticeActivityPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory PracticeActivityPageResponse.fromJson(Map<String, dynamic> json) {
    return PracticeActivityPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => PracticeActivityResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['currentPage'] as int,
      size: json['pageSize'] as int,
    );
  }
}