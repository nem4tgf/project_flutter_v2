class LearningMaterial {
  final int materialId;
  final int lessonId;
  final String materialType;
  final String materialUrl;
  final String description;

  LearningMaterial({
    required this.materialId,
    required this.lessonId,
    required this.materialType,
    required this.materialUrl,
    required this.description,
  });

  factory LearningMaterial.fromJson(Map<String, dynamic> json) {
    return LearningMaterial(
      materialId: json['materialId'] as int,
      lessonId: json['lessonId'] as int,
      // Sử dụng ?? '' để đảm bảo chuỗi không bao giờ null, khớp với cách dùng
      materialType: json['materialType'] as String? ?? '',
      materialUrl: json['materialUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'lessonId': lessonId,
      'materialType': materialType,
      'materialUrl': materialUrl,
      'description': description,
    };
  }
}