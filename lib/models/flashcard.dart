// lib/models/flashcard.dart
class FlashcardResponse {
  final int wordId;
  final String word;
  final String meaning;
  final String? exampleSentence;
  final String? pronunciation;
  final String? audioUrl;
  final String? writingPrompt;
  final String difficultyLevel;
  final bool isKnown; // Đảm bảo là bool

  FlashcardResponse({
    required this.wordId,
    required this.word,
    required this.meaning,
    this.exampleSentence,
    this.pronunciation,
    this.audioUrl,
    this.writingPrompt,
    required this.difficultyLevel,
    required this.isKnown,
  });

  factory FlashcardResponse.fromJson(Map<String, dynamic> json) {
    return FlashcardResponse(
      wordId: json['wordId'] as int,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      exampleSentence: json['exampleSentence'] as String?,
      pronunciation: json['pronunciation'] as String?,
      audioUrl: json['audioUrl'] as String?,
      writingPrompt: json['writingPrompt'] as String?,
      difficultyLevel: json['difficultyLevel'] as String,
      isKnown: json['isKnown'] as bool, // Rất quan trọng để cast đúng kiểu
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'word': word,
      'meaning': meaning,
      'exampleSentence': exampleSentence,
      'pronunciation': pronunciation,
      'audioUrl': audioUrl,
      'writingPrompt': writingPrompt,
      'difficultyLevel': difficultyLevel,
      'isKnown': isKnown,
    };
  }
}

// Thêm DTO cho yêu cầu đánh dấu flashcard
// lib/models/user_flashcard.dart (có thể tạo file riêng)
// Hoặc có thể định nghĩa trong flashcard.dart nếu bạn muốn giữ nó đơn giản
class UserFlashcardRequest {
  final int userId;
  final int wordId;
  final bool isKnown;

  UserFlashcardRequest({
    required this.userId,
    required this.wordId,
    required this.isKnown,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'wordId': wordId,
      'isKnown': isKnown,
    };
  }
}

// Response cho việc đánh dấu flashcard (nếu backend trả về)
class UserFlashcardResponse {
  final int id;
  final int userId;
  final int wordId;
  final bool isKnown;

  UserFlashcardResponse({
    required this.id,
    required this.userId,
    required this.wordId,
    required this.isKnown,
  });

  factory UserFlashcardResponse.fromJson(Map<String, dynamic> json) {
    return UserFlashcardResponse(
      id: json['id'] as int,
      userId: json['userId'] as int,
      wordId: json['wordId'] as int,
      isKnown: json['isKnown'] as bool,
    );
  }
}