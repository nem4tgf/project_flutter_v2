// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/quiz_result.dart';
// import '../../services/auth_service.dart';
// import '../../services/quiz_result_service.dart';
// import '../../widgets/quiz_result_item.dart';
//
// class QuizResultsTab extends StatefulWidget {
//   final int userId;
//   final Function() updateProgress; // CHANGED: Hàm để cập nhật tiến độ, không nhận đối số
//
//   const QuizResultsTab({
//     super.key,
//     required this.userId,
//     required this.updateProgress,
//   });
//
//   @override
//   State<QuizResultsTab> createState() => _QuizResultsTabState();
// }
//
// class _QuizResultsTabState extends State<QuizResultsTab> {
//   List<QuizResultResponse> _quizResults = [];
//   bool _isLoading = true;
//   String? _error;
//
//   late QuizResultService _quizResultService;
//
//   @override
//   void initState() {
//     super.initState();
//     final authService = Provider.of<AuthService>(context, listen: false);
//     _quizResultService = QuizResultService(authService);
//     _loadQuizResults();
//   }
//
//   Future<void> _loadQuizResults() async {
//     try {
//       final data = await _quizResultService.getQuizResultsByUser(widget.userId);
//       setState(() {
//         _quizResults = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)));
//     } else if (_error != null) {
//       return Center(
//         child: Text(
//           'Lỗi khi tải kết quả bài kiểm tra: $_error',
//           style: const TextStyle(color: Colors.redAccent, fontSize: 16),
//           textAlign: TextAlign.center,
//         ),
//       );
//     } else if (_quizResults.isEmpty) {
//       return const Center(
//         child: Text(
//           'Không có kết quả bài kiểm tra nào',
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
//         childAspectRatio: isSmallScreen ? 1.2 : 1.0,
//       ),
//       itemCount: _quizResults.length,
//       itemBuilder: (context, index) {
//         final result = _quizResults[index];
//         return QuizResultItem(
//           result: result,
//           isSmallScreen: isSmallScreen,
//         );
//       },
//     );
//   }
// }
