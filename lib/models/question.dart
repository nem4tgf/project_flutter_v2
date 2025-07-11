import 'package:collection/collection.dart';
import 'quiz.dart';

enum QuestionType {
  MULTIPLE_CHOICE,
  FILL_IN_THE_BLANK,
  DICTATION,
  SPEAKING_PROMPT,
  WRITING_PROMPT,
  MATCHING,
  TRUE_FALSE,
}

QuestionType? questionTypeFromString(String? type) {
  if (type == null) return null;
  return QuestionType.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == type.toUpperCase(),
  );
}

class QuestionRequest {
  final int quizId;
  final String questionText;
  final QuestionType questionType;
  final String? audioUrl;
  final String? imageUrl;
  final String? correctAnswerText;

  QuestionRequest({
    required this.quizId,
    required this.questionText,
    required this.questionType,
    this.audioUrl,
    this.imageUrl,
    this.correctAnswerText,
  });

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'questionText': questionText,
      'questionType': questionType.toString().split('.').last,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'correctAnswerText': correctAnswerText,
    };
  }
}

class QuestionResponse {
  final int? questionId;
  final int? quizId;
  final String? questionText;
  final QuestionType? questionType;
  final String? audioUrl;
  final String? imageUrl;
  final String? correctAnswerText;

  QuestionResponse({
    this.questionId,
    this.quizId,
    this.questionText,
    this.questionType,
    this.audioUrl,
    this.imageUrl,
    this.correctAnswerText,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      questionId: json['questionId'] as int?,
      quizId: json['quizId'] as int?,
      questionText: json['questionText'] as String?,
      questionType: questionTypeFromString(json['questionType'] as String?),
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      correctAnswerText: json['correctAnswerText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'quizId': quizId,
      'questionText': questionText,
      'questionType': questionType?.toString().split('.').last,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'correctAnswerText': correctAnswerText,
    };
  }

  bool get isError => questionId == null;
}

class QuestionSearchRequest {
  final int? quizId;
  final String? questionText;
  final QuestionType? questionType;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  QuestionSearchRequest({
    this.quizId,
    this.questionText,
    this.questionType,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = page != null && page >= 0 ? page : 0,
        size = size != null && size > 0 ? size : 10,
        sortBy = sortBy != null &&
            ['questionId', 'quizId', 'questionText', 'questionType'].contains(sortBy)
            ? sortBy
            : 'questionId',
        sortDir = sortDir != null && ['ASC', 'DESC'].contains(sortDir.toUpperCase()) ? sortDir : 'ASC';

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    if (quizId != null) params['quizId'] = quizId.toString();
    if (questionText != null && questionText!.isNotEmpty) params['questionText'] = questionText!;
    if (questionType != null) params['questionType'] = questionType.toString().split('.').last;
    return params;
  }
}

class QuestionPageResponse {
  final List<QuestionResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  QuestionPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory QuestionPageResponse.fromJson(Map<String, dynamic> json) {
    return QuestionPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => QuestionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['currentPage'] as int,
      size: json['pageSize'] as int,
    );
  }
}