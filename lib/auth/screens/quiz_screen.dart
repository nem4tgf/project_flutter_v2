// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/answer.dart';
// import '../../models/progress.dart';
// import '../../models/question.dart';
// import '../../models/quiz_result.dart';
// import '../../services/answer_service.dart';
// import '../../services/auth_service.dart';
// import '../../services/progress_service.dart';
// import '../../services/question_service.dart';
// import '../../services/quiz_result_service.dart';
// import 'package:collection/collection.dart';
//
// class QuizScreen extends StatefulWidget {
//   final int quizId;
//   final String quizTitle;
//   final int lessonId; // Cần để cập nhật progress
//   // REMOVED: final String lessonSkill; // ĐÃ XÓA: Không còn cần thiết, đã dùng activityType 'QUIZ'
//   final int userId; // Cần để gửi kết quả và cập nhật progress
//
//   const QuizScreen({
//     super.key,
//     required this.quizId,
//     required this.quizTitle,
//     required this.lessonId,
//     // REMOVED: lessonSkill (Xóa hoàn toàn khỏi constructor)
//     required this.userId,
//   });
//
//   @override
//   State<QuizScreen> createState() => _QuizScreenState();
// }
//
// class _QuizScreenState extends State<QuizScreen> {
//   late QuestionService _questionService;
//   late AnswerService _answerService;
//   late QuizResultService _quizResultService;
//   late ProgressService _progressService;
//
//   List<QuestionResponse> _questions = [];
//   Map<int, List<AnswerResponse>> _answersMap = {}; // Map: QuestionId -> List<Answers>
//   Map<int, int?> _userSelections = {}; // Map: QuestionId -> SelectedAnswerId (hoặc null nếu chưa chọn)
//
//   int _currentQuestionIndex = 0;
//   bool _isLoading = true;
//   String? _error;
//   bool _quizCompleted = false;
//   int _score = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     final authService = Provider.of<AuthService>(context, listen: false);
//     _questionService = QuestionService(authService);
//     _answerService = AnswerService(authService);
//     _quizResultService = QuizResultService(authService);
//     _progressService = ProgressService(authService);
//     _loadQuizData();
//   }
//
//   Future<void> _loadQuizData() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//
//     try {
//       final questions = await _questionService.getQuestionsByQuizId(widget.quizId);
//       _questions = questions;
//
//       for (var question in _questions) {
//         final answers = await _answerService.getAnswersByQuestionId(question.questionId);
//         _answersMap[question.questionId] = answers;
//         _userSelections[question.questionId] = null;
//       }
//
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi tải dữ liệu quiz: $_error')),
//       );
//     }
//   }
//
//   void _onAnswerSelected(int questionId, int selectedAnswerId) {
//     setState(() {
//       _userSelections[questionId] = selectedAnswerId;
//     });
//   }
//
//   void _nextQuestion() {
//     if (_currentQuestionIndex < _questions.length - 1) {
//       setState(() {
//         _currentQuestionIndex++;
//       });
//     } else {
//       _submitQuiz();
//     }
//   }
//
//   void _previousQuestion() {
//     if (_currentQuestionIndex > 0) {
//       setState(() {
//         _currentQuestionIndex--;
//       });
//     }
//   }
//
//   Future<void> _submitQuiz() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     int correctCount = 0;
//     for (var question in _questions) {
//       final selectedAnswerId = _userSelections[question.questionId];
//       final correctAnswers = _answersMap[question.questionId]?.where((ans) => ans.isCorrect).toList();
//
//       if (selectedAnswerId != null && correctAnswers != null && correctAnswers.isNotEmpty) {
//         if (correctAnswers.any((ans) => ans.answerId == selectedAnswerId)) {
//           correctCount++;
//         }
//       }
//     }
//
//     _score = (_questions.isEmpty ? 0 : (correctCount / _questions.length * 100)).round();
//
//     try {
//       final quizResultRequest = QuizResultRequest(
//         userId: widget.userId,
//         quizId: widget.quizId,
//         score: _score,
//       );
//       await _quizResultService.saveQuizResult(quizResultRequest);
//
//       final progressRequest = ProgressRequest(
//         userId: widget.userId,
//         lessonId: widget.lessonId,
//         activityType: 'QUIZ',
//         status: 'COMPLETED',
//         completionPercentage: _score,
//       );
//       await _progressService.updateProgress(progressRequest);
//
//       setState(() {
//         _quizCompleted = true;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi khi nộp bài hoặc cập nhật tiến độ: $_error')),
//       );
//     }
//   }
//
//   Widget _buildResultView(QuestionResponse question) {
//     final selectedAnswerId = _userSelections[question.questionId];
//     final answers = _answersMap[question.questionId] ?? [];
//
//     final correctAnswer = answers.firstWhereOrNull((ans) => ans.isCorrect);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Câu hỏi: ${question.questionText}',
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         ...answers.map((answer) {
//           bool isSelected = (selectedAnswerId == answer.answerId);
//           bool isCorrect = answer.isCorrect;
//           Color textColor = Colors.black87;
//           Color borderColor = Colors.grey;
//
//           if (_quizCompleted) {
//             if (isCorrect) {
//               textColor = Colors.green;
//               borderColor = Colors.green;
//             } else if (isSelected && !isCorrect) {
//               textColor = Colors.red;
//               borderColor = Colors.red;
//             }
//           }
//
//           return Container(
//             margin: const EdgeInsets.symmetric(vertical: 4),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               border: Border.all(color: borderColor),
//               borderRadius: BorderRadius.circular(8),
//               color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   isCorrect ? Icons.check_circle : (isSelected && !isCorrect ? Icons.cancel : Icons.radio_button_unchecked),
//                   color: isCorrect ? Colors.green : (isSelected && !isCorrect ? Colors.red : Colors.grey),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     answer.answerText,
//                     style: TextStyle(fontSize: 16, color: textColor),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//         if (_quizCompleted && correctAnswer != null && selectedAnswerId != correctAnswer.answerId)
//           Padding(
//             padding: const EdgeInsets.only(top: 10),
//             child: Text(
//               'Đáp án đúng là: ${correctAnswer.answerText}',
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
//             ),
//           ),
//         const Divider(),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.quizTitle),
//         backgroundColor: const Color(0xFF4A90E2),
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)))
//           : _error != null
//           ? Center(child: Text('Lỗi: $_error'))
//           : _questions.isEmpty
//           ? const Center(child: Text('Không có câu hỏi nào cho bài kiểm tra này.'))
//           : _quizCompleted
//           ? Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Bài kiểm tra đã hoàn thành!',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF50E3C2)),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Điểm của bạn: $_score/${_questions.length} (${_score}%)', // Fixed max score display
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               ..._questions.map((q) => _buildResultView(q)).toList(),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4A90E2),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: const Text('Quay lại', style: TextStyle(fontSize: 18)),
//               ),
//             ],
//           ),
//         ),
//       )
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Câu hỏi ${_currentQuestionIndex + 1}/${_questions.length}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A90E2)),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   _questions[_currentQuestionIndex].questionText,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView(
//                 children: (_answersMap[_questions[_currentQuestionIndex].questionId] ?? [])
//                     .map((answer) {
//                   return AnswerOption(
//                     answer: answer,
//                     isSelected: _userSelections[_questions[_currentQuestionIndex].questionId] == answer.answerId,
//                     onSelect: (selectedAnswerId) {
//                       _onAnswerSelected(_questions[_currentQuestionIndex].questionId, selectedAnswerId);
//                     },
//                   );
//                 }).toList(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 if (_currentQuestionIndex > 0)
//                   ElevatedButton(
//                     onPressed: _previousQuestion,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[300],
//                       foregroundColor: Colors.black87,
//                       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: const Text('Câu trước'),
//                   ),
//                 const Spacer(),
//                 ElevatedButton(
//                   onPressed: _userSelections[_questions[_currentQuestionIndex].questionId] != null
//                       ? _nextQuestion
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF50E3C2),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   child: Text(_currentQuestionIndex == _questions.length - 1 ? 'Nộp bài' : 'Câu tiếp theo'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class AnswerOption extends StatelessWidget {
//   final AnswerResponse answer;
//   final bool isSelected;
//   final ValueChanged<int> onSelect;
//
//   const AnswerOption({
//     super.key,
//     required this.answer,
//     required this.isSelected,
//     required this.onSelect,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: isSelected ? 4 : 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[300]!,
//           width: isSelected ? 2 : 1,
//         ),
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: InkWell(
//         onTap: () => onSelect(answer.answerId),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Icon(
//                 isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
//                 color: isSelected ? const Color(0xFF4A90E2) : Colors.grey,
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   answer.answerText,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
