import 'package:collection/collection.dart';
import 'lesson.dart';

enum QuizType {
  LISTENING_TEST,
  SPEAKING_TEST,
  READING_TEST,
  WRITING_TEST,
  GRAMMAR_TEST,
  VOCABULARY_TEST,
  COMPREHENSIVE_TEST,
}

QuizType? quizTypeFromString(String? type) {
  if (type == null) return null;
  return QuizType.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == type.toUpperCase(),
  );
}

class QuizRequest {
  final int lessonId;
  final String title;
  final QuizType quizType;

  QuizRequest({
    required this.lessonId,
    required this.title,
    required this.quizType,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'quizType': quizType.toString().split('.').last,
    };
  }
}

class QuizResponse {
  final int? quizId;
  final int? lessonId;
  final String? title;
  final QuizType? quizType;
  final DateTime? createdAt;

  QuizResponse({
    this.quizId,
    this.lessonId,
    this.title,
    this.quizType,
    this.createdAt,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      quizId: json['quizId'] as int?,
      lessonId: json['lessonId'] as int?,
      title: json['title'] as String?,
      quizType: quizTypeFromString(json['quizType'] as String?),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'lessonId': lessonId,
      'title': title,
      'quizType': quizType?.toString().split('.').last,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isError => quizId == null;
}

class QuizSearchRequest {
  final int? lessonId;
  final String? title;
  final QuizType? quizType;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  QuizSearchRequest({
    this.lessonId,
    this.title,
    this.quizType,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = page != null && page >= 0 ? page : 0,
        size = size != null && size > 0 ? size : 10,
        sortBy = sortBy != null &&
            ['quizId', 'lessonId', 'title', 'quizType', 'createdAt'].contains(sortBy)
            ? sortBy
            : 'quizId',
        sortDir = sortDir != null && ['ASC', 'DESC'].contains(sortDir.toUpperCase()) ? sortDir : 'ASC';

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    if (lessonId != null) params['lessonId'] = lessonId.toString();
    if (title != null && title!.isNotEmpty) params['title'] = title!;
    if (quizType != null) params['quizType'] = quizType.toString().split('.').last;
    return params;
  }
}

class QuizPageResponse {
  final List<QuizResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  QuizPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory QuizPageResponse.fromJson(Map<String, dynamic> json) {
    return QuizPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => QuizResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['currentPage'] as int,
      size: json['pageSize'] as int,
    );
  }
}