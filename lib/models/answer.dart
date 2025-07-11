import 'package:flutter/material.dart'; // Giữ lại nếu bạn có lý do dùng Material trong model, nếu không có thể xóa

// --- AnswerRequest DTO ---
// Dùng để gửi dữ liệu tạo/cập nhật câu trả lời lên backend
class AnswerRequest {
  final int questionId;
  final String answerText;
  final bool isCorrect;
  final bool isActive; // ĐÃ THÊM: Đồng bộ với backend

  AnswerRequest({
    required this.questionId,
    required this.answerText,
    required this.isCorrect,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'content': answerText, // Backend mong đợi 'content'
      'isCorrect': isCorrect,
      'isActive': isActive,
    };
  }
}

// --- AnswerResponse DTO ---
// Dùng để nhận dữ liệu câu trả lời từ backend
class AnswerResponse {
  final int answerId;
  final int questionId;
  final String answerText;
  final bool isCorrect;
  final bool isActive;
  final bool isDeleted; // ĐÃ THÊM: Đồng bộ với backend

  AnswerResponse({
    required this.answerId,
    required this.questionId,
    required this.answerText,
    required this.isCorrect,
    required this.isActive,
    required this.isDeleted,
  });

  factory AnswerResponse.fromJson(Map<String, dynamic> json) {
    return AnswerResponse(
      answerId: json['answerId'] as int,
      questionId: json['questionId'] as int,
      answerText: json['content'] as String, // Backend trả về 'content'
      isCorrect: json['isCorrect'] as bool,
      isActive: json['isActive'] as bool,
      isDeleted: json['isDeleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    // Phương thức này có thể không cần thiết nếu bạn chỉ dùng AnswerResponse để nhận dữ liệu
    // nhưng giữ lại để đồng bộ với cấu trúc ban đầu của bạn.
    return {
      'answerId': answerId,
      'questionId': questionId,
      'content': answerText,
      'isCorrect': isCorrect,
      'isActive': isActive,
      'isDeleted': isDeleted,
    };
  }
}

// --- AnswerSearchRequest DTO ---
// Dùng để gửi các tiêu chí tìm kiếm câu trả lời lên backend
class AnswerSearchRequest {
  final int? questionId;
  final bool? isCorrect;
  final bool? isActive;
  final bool? isDeleted; // ĐÃ THÊM: Đồng bộ với backend
  final String? answerText;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  AnswerSearchRequest({
    this.questionId,
    this.isCorrect,
    this.isActive,
    this.isDeleted, // Cho phép tìm kiếm theo isDeleted
    this.answerText,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : // Áp dụng giá trị mặc định tương tự backend
        page = (page == null || page < 0) ? 0 : page,
        size = (size == null || size <= 0) ? 10 : size,
        sortBy = (sortBy == null || sortBy.isEmpty ||
            !(sortBy == 'answerId' ||
                sortBy == 'answerText' ||
                sortBy == 'isCorrect' ||
                sortBy == 'isActive' ||
                sortBy == 'isDeleted')) // Cập nhật các trường có thể sort
            ? 'answerId'
            : sortBy,
        sortDir = (sortDir == null || sortDir.isEmpty) ? 'ASC' : sortDir;

  Map<String, dynamic> toJson() {
    // Chỉ bao gồm các trường có giá trị không null
    final Map<String, dynamic> json = {
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (questionId != null) json['questionId'] = questionId;
    if (isCorrect != null) json['isCorrect'] = isCorrect;
    if (isActive != null) json['isActive'] = isActive;
    if (isDeleted != null) json['isDeleted'] = isDeleted; // Thêm vào JSON nếu có
    if (answerText != null && answerText!.isNotEmpty) json['answerText'] = answerText;

    return json;
  }
}

// --- paginated_response.dart DTO (Generic) ---
// Dùng để xử lý phản hồi phân trang từ backend (ví dụ: Page<AnswerResponse>)
// File này thường được đặt riêng (ví dụ: `lib/models/paginated_response.dart`)
// nếu bạn dùng nó cho nhiều kiểu dữ liệu khác nhau.
// Tuy nhiên, theo yêu cầu gộp, tôi sẽ đặt nó ở đây.
class PaginatedResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int number; // current page number (0-indexed)
  final int size; // page size
  final bool first;
  final bool last;

  PaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PaginatedResponse<T>(
      content: (json['content'] as List<dynamic>).map<T>((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      number: json['number'] as int,
      size: json['size'] as int,
      first: json['first'] as bool,
      last: json['last'] as bool,
    );
  }
}