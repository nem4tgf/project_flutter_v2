// // lib/widgets/quiz_result_item.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Để định dạng ngày tháng
//
// import '../../models/quiz_result.dart'; // Import model QuizResultResponse
//
// class QuizResultItem extends StatelessWidget {
//   final QuizResultResponse result;
//   final bool isSmallScreen;
//
//   const QuizResultItem({
//     super.key,
//     required this.result,
//     required this.isSmallScreen,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.zero, // Card đã có padding từ GridView/ListView
//       elevation: 6,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       clipBehavior: Clip.antiAlias,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Icon(
//               result.score >= 70 ? Icons.check_circle_outline : Icons.cancel_outlined, // Ví dụ: điểm > 70 là pass
//               color: result.score >= 70 ? Colors.green.shade600 : Colors.red.shade600,
//               size: isSmallScreen ? 50 : 60,
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Điểm của bạn:',
//               style: TextStyle(
//                 fontSize: isSmallScreen ? 16 : 18,
//                 color: Colors.grey[700],
//               ),
//             ),
//             Text(
//               '${result.score}',
//               style: TextStyle(
//                 fontSize: isSmallScreen ? 36 : 48,
//                 fontWeight: FontWeight.bold,
//                 color: result.score >= 70 ? Colors.green.shade800 : Colors.red.shade800,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Quiz ID: ${result.quizId}', // Có thể hiển thị tên quiz nếu bạn có thông tin đó
//               style: TextStyle(
//                 fontSize: isSmallScreen ? 14 : 16,
//                 color: Colors.black54,
//               ),
//             ),
//             Text(
//               'Hoàn thành lúc: ${DateFormat('HH:mm dd/MM/yyyy').format(result.completedAt)}',
//               style: TextStyle(
//                 fontSize: isSmallScreen ? 12 : 14,
//                 color: Colors.black54,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }