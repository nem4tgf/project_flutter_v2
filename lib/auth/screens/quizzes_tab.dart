// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/quiz.dart';
// import '../../services/auth_service.dart';
// import '../../services/quiz_service.dart';
// import '../../widgets/quiz_item.dart';
// import 'quiz_screen.dart';
//
// class QuizzesTab extends StatefulWidget {
//   final Future<List<QuizResponse>> quizzesFuture;
//   final Function() updateProgress; // CHANGED: Hàm để cập nhật tiến độ, không nhận đối số
//   final int userId;
//   final int lessonId; // ADDED: Thêm lessonId để truyền xuống QuizScreen
//
//   const QuizzesTab({
//     super.key,
//     required this.quizzesFuture,
//     required this.updateProgress,
//     required this.userId,
//     required this.lessonId, // ADDED: Yêu cầu lessonId
//   });
//
//   @override
//   State<QuizzesTab> createState() => _QuizzesTabState();
// }
//
// class _QuizzesTabState extends State<QuizzesTab> {
//   List<QuizResponse> _quizzes = [];
//   bool _isLoading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadQuizzes();
//   }
//
//   Future<void> _loadQuizzes() async {
//     try {
//       final data = await widget.quizzesFuture;
//       setState(() {
//         _quizzes = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//       debugPrint('Error loading quizzes: $e');
//     }
//   }
//
//   void _handleTakeQuiz(QuizResponse quiz) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => QuizScreen(
//           quizId: quiz.quizId,
//           quizTitle: quiz.title,
//           lessonId: widget.lessonId, // Sử dụng lessonId từ widget cha
//           // REMOVED: lessonSkill: quiz.skill, // ĐÃ XÓA: Không còn cần thiết cho QuizScreen
//           userId: widget.userId,
//         ),
//       ),
//     ).then((_) {
//       // Khi quay lại từ QuizScreen, gọi callback để cập nhật tiến độ tổng thể của bài học
//       widget.updateProgress();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)));
//     } else if (_error != null) {
//       return Center(
//         child: Text(
//           'Lỗi khi tải bài kiểm tra: $_error',
//           style: const TextStyle(color: Colors.redAccent, fontSize: 16),
//           textAlign: TextAlign.center,
//         ),
//       );
//     } else if (_quizzes.isEmpty) {
//       return const Center(
//         child: Text(
//           'Không có bài kiểm tra nào',
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//       );
//     }
//
//     final isSmallScreen = MediaQuery.of(context).size.width < 600;
//
//     return GridView.builder(
//       padding: const EdgeInsets.all(12),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: isSmallScreen ? 1 : 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: isSmallScreen ? 1.4 : 1.2,
//       ),
//       itemCount: _quizzes.length,
//       itemBuilder: (context, index) {
//         final quiz = _quizzes[index];
//         return QuizItem(
//           quiz: quiz,
//           onTakeQuiz: _handleTakeQuiz,
//           isSmallScreen: isSmallScreen,
//         );
//       },
//     );
//   }
// }
