// lib/widgets/quiz_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../models/quiz.dart'; // Import model QuizResponse

class QuizItem extends StatelessWidget {
  final QuizResponse quiz;
  // CẦN THAY ĐỔI DÒNG NÀY: onTakeQuiz phải nhận một QuizResponse
  final Function(QuizResponse quiz) onTakeQuiz; // Thay đổi từ int quizId sang QuizResponse quiz
  final bool isSmallScreen;

  const QuizItem({
    super.key,
    required this.quiz,
    required this.onTakeQuiz,
    required this.isSmallScreen,
  });

  // Hàm để lấy icon dựa trên loại kỹ năng
  IconData _getSkillIcon(String skill) {
    switch (skill.toUpperCase()) {
      case 'LISTENING':
        return Icons.hearing;
      case 'SPEAKING':
      case 'READING':
        return Icons.menu_book;
      case 'WRITING':
        return Icons.edit;
      case 'VOCABULARY':
        return Icons.sort_by_alpha;
      case 'GRAMMAR':
        return Icons.rule_folder;
      default:
        return AntDesign.questioncircleo; // Icon mặc định
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Card đã có padding từ GridView
      elevation: 6, // Tăng đổ bóng
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Bo tròn góc
      clipBehavior: Clip.antiAlias, // Cắt nội dung theo bo góc
      child: InkWell(
        // CẦN THAY ĐỔI DÒNG NÀY: Truyền toàn bộ đối tượng quiz vào callback
        onTap: () => onTakeQuiz(quiz), // Gọi callback khi chạm vào thẻ, truyền toàn bộ quiz
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
            children: [
              Icon(
                _getSkillIcon(quiz.skill),
                color: const Color(0xFF4A90E2),
                size: isSmallScreen ? 40 : 50,
              ),
              const SizedBox(height: 10),
              Text(
                quiz.title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                'Kỹ năng: ${quiz.skill}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(), // Đẩy nút xuống dưới cùng
              ElevatedButton.icon(
                // CẦN THAY ĐỔI DÒNG NÀY: Truyền toàn bộ đối tượng quiz vào callback
                onPressed: () => onTakeQuiz(quiz), // Truyền toàn bộ quiz
                icon: Icon(Icons.play_arrow, color: Colors.white, size: isSmallScreen ? 18 : 22),
                label: Text(
                  'Bắt đầu làm bài',
                  style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 14 : 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50E3C2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 15 : 20, vertical: isSmallScreen ? 8 : 10),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}