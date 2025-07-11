import 'package:flutter_auth_app/models/auth_models.dart'; // Import Role nếu cần

class UserSpeakingAttemptRequest {
  final int userId;
  final int practiceActivityId;
  final String userAudioUrl;
  final String userTranscribedBySTT;
  final int pronunciationScore;
  final int? fluencyScore;
  final int overallScore;

  UserSpeakingAttemptRequest({
    required this.userId,
    required this.practiceActivityId,
    required this.userAudioUrl,
    required this.userTranscribedBySTT,
    required this.pronunciationScore,
    this.fluencyScore,
    required this.overallScore,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'practiceActivityId': practiceActivityId,
    'userAudioUrl': userAudioUrl,
    'userTranscribedBySTT': userTranscribedBySTT,
    'pronunciationScore': pronunciationScore,
    if (fluencyScore != null) 'fluencyScore': fluencyScore,
    'overallScore': overallScore,
  };
}

class UserSpeakingAttemptResponse {
  final int? attemptId;
  final int? userId;
  final int? practiceActivityId;
  final String? userAudioUrl;
  final String? userTranscribedBySTT;
  final int? pronunciationScore;
  final int? fluencyScore;
  final int? overallScore;
  final DateTime? attemptDate;

  UserSpeakingAttemptResponse({
    this.attemptId,
    this.userId,
    this.practiceActivityId,
    this.userAudioUrl,
    this.userTranscribedBySTT,
    this.pronunciationScore,
    this.fluencyScore,
    this.overallScore,
    this.attemptDate,
  });

  factory UserSpeakingAttemptResponse.fromJson(Map<String, dynamic> json) {
    return UserSpeakingAttemptResponse(
      attemptId: json['attemptId'] as int?,
      userId: json['userId'] as int?,
      practiceActivityId: json['practiceActivityId'] as int?,
      userAudioUrl: json['userAudioUrl'] as String?,
      userTranscribedBySTT: json['userTranscribedBySTT'] as String?,
      pronunciationScore: json['pronunciationScore'] as int?,
      fluencyScore: json['fluencyScore'] as int?,
      overallScore: json['overallScore'] as int?,
      attemptDate: json['attemptDate'] != null
          ? DateTime.parse(json['attemptDate'] as String)
          : null,
    );
  }
}

class UserSpeakingAttemptSearchRequest {
  final int? userId;
  final int? practiceActivityId;
  final int? minOverallScore;
  final int? maxOverallScore;
  final int page;
  final int size;

  UserSpeakingAttemptSearchRequest({
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

class UserSpeakingAttemptPageResponse {
  final List<UserSpeakingAttemptResponse> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  UserSpeakingAttemptPageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory UserSpeakingAttemptPageResponse.fromJson(Map<String, dynamic> json) {
    var contentList = (json['content'] as List<dynamic>)
        .map((e) => UserSpeakingAttemptResponse.fromJson(e as Map<String, dynamic>))
        .toList();
    return UserSpeakingAttemptPageResponse(
      content: contentList,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      number: json['number'] as int,
      size: json['size'] as int,
    );
  }
}