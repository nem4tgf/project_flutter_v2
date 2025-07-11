import 'package:collection/collection.dart';

class QuizResultRequest {
  final int userId;
  final int quizId;
  final int score;
  final int? durationSeconds;

  QuizResultRequest({
    required this.userId,
    required this.quizId,
    required this.score,
    this.durationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'durationSeconds': durationSeconds,
    };
  }
}

class QuizResultResponse {
  final int? resultId;
  final int? userId;
  final int? quizId;
  final int? score;
  final DateTime? completedAt;
  final int? durationSeconds;

  QuizResultResponse({
    this.resultId,
    this.userId,
    this.quizId,
    this.score,
    this.completedAt,
    this.durationSeconds,
  });

  factory QuizResultResponse.fromJson(Map<String, dynamic> json) {
    return QuizResultResponse(
      resultId: json['resultId'] as int?,
      userId: json['userId'] as int?,
      quizId: json['quizId'] as int?,
      score: json['score'] as int?,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      durationSeconds: json['durationSeconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultId': resultId,
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'completedAt': completedAt?.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  bool get isError => resultId == null;
}

class QuizResultSearchRequest {
  final int? userId;
  final int? quizId;
  final double? minScore;
  final double? maxScore;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  QuizResultSearchRequest({
    this.userId,
    this.quizId,
    this.minScore,
    this.maxScore,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = page != null && page >= 0 ? page : 0,
        size = size != null && size > 0 ? size : 10,
        sortBy = sortBy != null &&
            ['resultId', 'userId', 'quizId', 'score', 'completedAt', 'durationSeconds'].contains(sortBy)
            ? sortBy
            : 'resultId',
        sortDir = sortDir != null && ['ASC', 'DESC'].contains(sortDir.toUpperCase()) ? sortDir : 'ASC';

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    if (userId != null) params['userId'] = userId.toString();
    if (quizId != null) params['quizId'] = quizId.toString();
    if (minScore != null) params['minScore'] = minScore.toString();
    if (maxScore != null) params['maxScore'] = maxScore.toString();
    return params;
  }
}

class QuizResultPageResponse {
  final List<QuizResultResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  QuizResultPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory QuizResultPageResponse.fromJson(Map<String, dynamic> json) {
    return QuizResultPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => QuizResultResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['currentPage'] as int,
      size: json['pageSize'] as int,
    );
  }
}