enum DifficultyLevel { EASY, MEDIUM, HARD }

class VocabularyRequest {
  final String word;
  final String meaning;
  final String? exampleSentence;
  final String? pronunciation;
  final String? audioUrl;
  final String? imageUrl;
  final String? writingPrompt;
  final DifficultyLevel difficultyLevel;

  VocabularyRequest({
    required this.word,
    required this.meaning,
    this.exampleSentence,
    this.pronunciation,
    this.audioUrl,
    this.imageUrl,
    this.writingPrompt,
    required this.difficultyLevel,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'meaning': meaning,
    if (exampleSentence != null) 'exampleSentence': exampleSentence,
    if (pronunciation != null) 'pronunciation': pronunciation,
    if (audioUrl != null) 'audioUrl': audioUrl,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (writingPrompt != null) 'writingPrompt': writingPrompt,
    'difficultyLevel': difficultyLevel.toString().split('.').last,
  };
}

class VocabularyResponse {
  final int? wordId;
  final String? word;
  final String? meaning;
  final String? exampleSentence;
  final String? pronunciation;
  final String? audioUrl;
  final String? imageUrl;
  final String? writingPrompt;
  final DifficultyLevel? difficultyLevel;

  VocabularyResponse({
    this.wordId,
    this.word,
    this.meaning,
    this.exampleSentence,
    this.pronunciation,
    this.audioUrl,
    this.imageUrl,
    this.writingPrompt,
    this.difficultyLevel,
  });

  factory VocabularyResponse.fromJson(Map<String, dynamic> json) {
    return VocabularyResponse(
      wordId: json['wordId'] as int?,
      word: json['word'] as String?,
      meaning: json['meaning'] as String?,
      exampleSentence: json['exampleSentence'] as String?,
      pronunciation: json['pronunciation'] as String?,
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      writingPrompt: json['writingPrompt'] as String?,
      difficultyLevel: json['difficultyLevel'] != null
          ? DifficultyLevel.values.firstWhere(
              (e) => e.toString().split('.').last == json['difficultyLevel'],
          orElse: () => DifficultyLevel.EASY)
          : null,
    );
  }
}

class VocabularySearchRequest {
  final String? word;
  final String? meaning;
  final DifficultyLevel? difficultyLevel;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  VocabularySearchRequest({
    this.word,
    this.meaning,
    this.difficultyLevel,
    this.page = 0,
    this.size = 10,
    this.sortBy = 'wordId',
    this.sortDir = 'ASC',
  });

  Map<String, dynamic> toJson() => {
    if (word != null) 'word': word,
    if (meaning != null) 'meaning': meaning,
    if (difficultyLevel != null) 'difficultyLevel': difficultyLevel.toString().split('.').last,
    'page': page,
    'size': size,
    'sortBy': sortBy,
    'sortDir': sortDir,
  };
}

class VocabularyPageResponse {
  final List<VocabularyResponse> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  VocabularyPageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory VocabularyPageResponse.fromJson(Map<String, dynamic> json) {
    var contentList = (json['content'] as List<dynamic>)
        .map((e) => VocabularyResponse.fromJson(e as Map<String, dynamic>))
        .toList();
    return VocabularyPageResponse(
      content: contentList,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      number: json['number'] as int,
      size: json['size'] as int,
    );
  }
}