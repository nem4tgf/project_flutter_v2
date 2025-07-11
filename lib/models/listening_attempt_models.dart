import 'package:flutter_auth_app/models/auth_models.dart'; // Import Role nếu cần

class UserListeningAttemptRequest {
  final int userId;
  final int practiceActivityId;
  final String userTranscribedText;
  final int accuracyScore;

  UserListeningAttemptRequest({
    required this.userId,
    required this.practiceActivityId,
    required this.userTranscribedText,
    required this.accuracyScore,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'practiceActivityId': practiceActivityId,
    'userTranscribedText': userTranscribedText,
    'accuracyScore': accuracyScore,
  };
}

class UserListeningAttemptResponse {
  final int? attemptId;
  final int? userId;
  final int? practiceActivityId;
  final String? userTranscribedText;
  final int? accuracyScore;
  final DateTime? attemptDate;

  UserListeningAttemptResponse({
    this.attemptId,
    this.userId,
    this.practiceActivityId,
    this.userTranscribedText,
    this.accuracyScore,
    this.attemptDate,
  });

  factory UserListeningAttemptResponse.fromJson(Map<String, dynamic> json) {
    return UserListeningAttemptResponse(
      attemptId: json['attemptId'] as int?,
      userId: json['userId'] as int?,
      practiceActivityId: json['practiceActivityId'] as int?,
      userTranscribedText: json['userTranscribedText'] as String?,
      accuracyScore: json['accuracyScore'] as int?,
      attemptDate: json['attemptDate'] != null
          ? DateTime.parse(json['attemptDate'] as String)
          : null,
    );
  }
}

class UserListeningAttemptSearchRequest {
  final int? userId;
  final int? practiceActivityId;
  final int? minAccuracyScore;
  final int? maxAccuracyScore;
  final int page;
  final int size;

  UserListeningAttemptSearchRequest({
    this.userId,
    this.practiceActivityId,
    this.minAccuracyScore,
    this.maxAccuracyScore,
    this.page = 0,
    this.size = 10,
  });

  Map<String, dynamic> toJson() => {
    if (userId != null) 'userId': userId,
    if (practiceActivityId != null) 'practiceActivityId': practiceActivityId,
    if (minAccuracyScore != null) 'minAccuracyScore': minAccuracyScore,
    if (maxAccuracyScore != null) 'maxAccuracyScore': maxAccuracyScore,
    'page': page,
    'size': size,
  };
}

class UserListeningAttemptPageResponse {
  final List<UserListeningAttemptResponse> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  UserListeningAttemptPageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory UserListeningAttemptPageResponse.fromJson(Map<String, dynamic> json) {
    var contentList = (json['content'] as List<dynamic>)
        .map((e) => UserListeningAttemptResponse.fromJson(e as Map<String, dynamic>))
        .toList();
    return UserListeningAttemptPageResponse(
      content: contentList,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      number: json['number'] as int,
      size: json['size'] as int,
    );
  }
}