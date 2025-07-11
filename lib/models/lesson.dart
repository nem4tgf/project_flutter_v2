import 'package:collection/collection.dart';

// --- Enums tương ứng với Lesson.Level và Lesson.Skill của backend ---

// Level enum
enum Level {
  BEGINNER,
  INTERMEDIATE,
  ADVANCED,
  ALL_LEVELS,
}

// Hàm tiện ích để chuyển đổi String sang Level
Level? levelFromString(String? level) {
  if (level == null) return null;
  return Level.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == level.toUpperCase(),
  );
}

// Skill enum
enum Skill {
  LISTENING,
  SPEAKING,
  READING,
  WRITING,
  VOCABULARY,
  GRAMMAR,
  PRONUNCIATION,
  ALL_SKILLS,
}

// Hàm tiện ích để chuyển đổi String sang Skill
Skill? skillFromString(String? skill) {
  if (skill == null) return null;
  return Skill.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == skill.toUpperCase(),
  );
}

// --- LessonRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.LessonRequest.java
class LessonRequest {
  final String title;
  final String? description;
  final Level level;
  final Skill skill;
  final double price;

  LessonRequest({
    required this.title,
    this.description,
    required this.level,
    required this.skill,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'level': level.toString().split('.').last,
      'skill': skill.toString().split('.').last,
      'price': price,
    };
  }
}

// --- LessonResponse DTO ---
// Tương ứng với org.example.projetc_backend.dto.LessonResponse.java
class LessonResponse {
  final int? lessonId; // Nullable để xử lý lỗi
  final String? title;
  final String? description;
  final Level? level;
  final Skill? skill;
  final double? price;
  final DateTime? createdAt;
  final bool? isDeleted;

  LessonResponse({
    this.lessonId,
    this.title,
    this.description,
    this.level,
    this.skill,
    this.price,
    this.createdAt,
    this.isDeleted,
  });

  factory LessonResponse.fromJson(Map<String, dynamic> json) {
    return LessonResponse(
      lessonId: json['lessonId'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      level: levelFromString(json['level'] as String?),
      skill: skillFromString(json['skill'] as String?),
      price: (json['price'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      isDeleted: json['isDeleted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'level': level?.toString().split('.').last,
      'skill': skill?.toString().split('.').last,
      'price': price,
      'createdAt': createdAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  // Kiểm tra xem response có phải là lỗi không
  bool get isError => lessonId == null;
}

// --- LessonSearchRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.LessonSearchRequest.java
class LessonSearchRequest {
  final String? title;
  final String? level; // Backend dùng String cho level/skill trong SearchRequest
  final String? skill;
  final double? minPrice;
  final double? maxPrice;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  LessonSearchRequest({
    this.title,
    this.level,
    this.skill,
    this.minPrice,
    this.maxPrice,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = (page == null || page < 0) ? 0 : page,
        size = (size == null || size <= 0) ? 10 : size,
        sortBy = (sortBy == null || sortBy.isEmpty ||
            !(sortBy == 'lessonId' ||
                sortBy == 'title' ||
                sortBy == 'price' ||
                sortBy == 'level' ||
                sortBy == 'skill' ||
                sortBy == 'createdAt'))
            ? 'lessonId'
            : sortBy,
        sortDir = (sortDir == null || sortDir.isEmpty ||
            !(sortDir.toUpperCase() == 'ASC' || sortDir.toUpperCase() == 'DESC'))
            ? 'ASC'
            : sortDir;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (title != null && title!.isNotEmpty) json['title'] = title;
    if (level != null && level!.isNotEmpty) json['level'] = level;
    if (skill != null && skill!.isNotEmpty) json['skill'] = skill;
    if (minPrice != null) json['minPrice'] = minPrice;
    if (maxPrice != null) json['maxPrice'] = maxPrice;

    return json;
  }
}

// --- LessonPageResponse DTO ---
// Tương ứng với org.example.projetc_backend.dto.LessonPageResponse.java
class LessonPageResponse {
  final List<LessonResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  LessonPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory LessonPageResponse.fromJson(Map<String, dynamic> json) {
    return LessonPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => LessonResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }
}