import 'package:flutter_auth_app/models/auth_models.dart'; // Import Role nếu cần

class UserWritingAttemptRequest {
  final int userId;
  final int practiceActivityId;
  final String userWrittenText;
  final String? grammarFeedback;
  final String? spellingFeedback;
  final String? cohesionFeedback;
  final int? overallScore;

  UserWritingAttemptRequest({
    required this.userId,
    required this.practiceActivityId,
    required this.userWrittenText,
    this.grammarFeedback,
    this.spellingFeedback,
    this.cohesionFeedback,
    this.overallScore,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'practiceActivityId': practiceActivityId,
    'userWrittenText': userWrittenText,
    if (grammarFeedback != null) 'grammarFeedback': grammarFeedback,
    if (spellingFeedback != null) 'spellingFeedback': spellingFeedback,
    if (cohesionFeedback != null) 'cohesionFeedback': cohesionFeedback,
    if (overallScore != null) 'overallScore': overallScore,
  };
}

class UserWritingAttemptResponse {
  final int? attemptId;
  final int? userId;
  final int? practiceActivityId;
  final String? userWrittenText;
  final String? grammarFeedback;
  final String? spellingFeedback;
  final String? cohesionFeedback;
  final int? overallScore;
  final DateTime? attemptDate;

  UserWritingAttemptResponse({
    this.attemptId,
    this.userId,
    this.practiceActivityId,
    this.userWrittenText,
    this.grammarFeedback,
    this.spellingFeedback,
    this.cohesionFeedback,
    this.overallScore,
    this.attemptDate,
  });

  factory UserWritingAttemptResponse.fromJson(Map<String, dynamic> json) {
    return UserWritingAttemptResponse(
      attemptId: json['attemptId'] as int?,
      userId: json['userId'] as int?,
      practiceActivityId: json['practiceActivityId'] as int?,
      userWrittenText: json['userWrittenText'] as String?,
      grammarFeedback: json['grammarFeedback'] as String?,
      spellingFeedback: json['spellingFeedback'] as String?,
      cohesionFeedback: json['cohesionFeedback'] as String?,
      overallScore: json['overallScore'] as int?,
      attemptDate: json['attemptDate'] != null
          ? DateTime.parse(json['attemptDate'] as String)
          : null,
    );
  }
}

class UserWritingAttemptSearchRequest {
  final int? userId;
  final int? practiceActivityId;
  final int? minOverallScore;
  final int? maxOverallScore;
  final int page;
  final int size;

  UserWritingAttemptSearchRequest({
    this.userId,
    this.practiceActivityId,
    this.minOverallScore,
    this.maxOverallScore,
    this.page = 0,
    this.size = 10,
  });

  Map<String, dynamic> toJson() => {
    if (userId != null) 'userId': userId,
    if (practiceActivityId != null) 'practiceActivityId': practiceActivityId,
    if (minOverallScore != null) 'minOverallScore': minOverallScore,
    if (maxOverallScore != null) 'maxOverallScore': maxOverallScore,
    'page': page,
    'size': size,
  };
}

class UserWritingAttemptPageResponse {
  final List<UserWritingAttemptResponse> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  UserWritingAttemptPageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory UserWritingAttemptPageResponse.fromJson(Map<String, dynamic> json) {
    var contentList = (json['content'] as List<dynamic>)
        .map((e) => UserWritingAttemptResponse.fromJson(e as Map<String, dynamic>))
        .toList();
    return UserWritingAttemptPageResponse(
      content: contentList,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      number: json['number'] as int,
      size: json['size'] as int,
    );
  }
}