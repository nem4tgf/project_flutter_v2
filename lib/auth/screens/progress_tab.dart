// // lib/screens/progress_tab.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:provider/provider.dart';
// import '../../models/progress.dart';
// import '../../services/auth_service.dart';
// import '../../services/progress_service.dart';
// import 'package:flutter/foundation.dart';
//
// class ProgressTab extends StatefulWidget {
//   final int userId;
//   final int lessonId;
//   // REMOVED: lessonSkill (vì tab này hiển thị tổng quan, không phải skill cụ thể)
//   final Function() updateOverallProgress; // CHANGED: Callback now takes no arguments
//
//   const ProgressTab({
//     super.key,
//     required this.userId,
//     required this.lessonId,
//     // REMOVED: required this.lessonSkill,
//     required this.updateOverallProgress,
//   });
//
//   @override
//   State<ProgressTab> createState() => _ProgressTabState();
// }
//
// class _ProgressTabState extends State<ProgressTab> {
//   ProgressResponse? _overallProgress; // Now stores overall lesson progress
//   bool _isLoading = true;
//   String? _error;
//   late ProgressService _progressService;
//   late int _localOverallCompletionPercentage; // Local variable for overall percentage display
//
//   @override
//   void initState() {
//     super.initState();
//     final authService = Provider.of<AuthService>(context, listen: false);
//     _progressService = ProgressService(authService);
//     _loadOverallProgress(); // Load overall progress when this tab is initialized
//   }
//
//   Future<void> _loadOverallProgress() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final overallProgress = await _progressService.getOverallLessonProgress(
//         widget.userId,
//         widget.lessonId,
//       );
//       setState(() {
//         _overallProgress = overallProgress;
//         _localOverallCompletionPercentage = overallProgress.completionPercentage;
//         _isLoading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading overall progress: $e');
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//         _overallProgress = null;
//         _localOverallCompletionPercentage = 0; // Default to 0% if error or not found
//       });
//     }
//   }
//
//   // THIS METHOD IS ONLY FOR DEMONSTRATION/TESTING.
//   // In a real app, individual activity updates should come from specific activity screens/widgets.
//   // This method simulates an update to 'READING_MATERIAL' and refreshes overall progress.
//   Future<void> _updateDummyActivityProgressOnBackend(int newPercentage) async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//
//     try {
//       final dummyActivityType = 'READING_MATERIAL'; // Simulating an update to a specific activity
//       final request = ProgressRequest(
//         userId: widget.userId,
//         lessonId: widget.lessonId,
//         activityType: dummyActivityType,
//         status: newPercentage == 100 ? 'COMPLETED' : 'IN_PROGRESS',
//         completionPercentage: newPercentage,
//       );
//
//       await _progressService.updateProgress(request);
//
//       // After updating an activity, refresh the overall progress
//       await _loadOverallProgress();
//       widget.updateOverallProgress(); // Notify parent to refresh its overall progress display
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Cập nhật tiến độ cho $dummyActivityType thành ${newPercentage}%!'),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Lỗi cập nhật tiến độ: $_error'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
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
//           'Lỗi: $_error',
//           style: const TextStyle(color: Colors.redAccent, fontSize: 16),
//           textAlign: TextAlign.center,
//         ),
//       );
//     }
//
//     final isSmallScreen = MediaQuery.of(context).size.width < 600;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: isSmallScreen ? 150 : 200,
//             height: isSmallScreen ? 150 : 200,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: const Color(0xFF4A90E2), width: 4),
//             ),
//             child: Center(
//               child: Text(
//                 '${_localOverallCompletionPercentage}%', // Display overall percentage
//                 style: TextStyle(
//                   fontSize: isSmallScreen ? 40 : 50,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF50E3C2),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Tiến độ hoàn thành bài học', // CHANGED: More generic title
//             style: TextStyle(
//               fontSize: isSmallScreen ? 20 : 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Đây là tiến độ tổng thể của bạn cho bài học này, dựa trên các hoạt động đã hoàn thành.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.black54,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 30),
//
//           // Demo Slider and Button for manual update of a DUMMY activity
//           // In a real app, these would be removed from ProgressTab,
//           // and updates would come from specific activity screens/widgets.
//           Slider(
//             value: _localOverallCompletionPercentage.toDouble(),
//             min: 0.0,
//             max: 100.0,
//             divisions: 100,
//             activeColor: const Color(0xFF4A90E2),
//             inactiveColor: Colors.grey[300],
//             label: _localOverallCompletionPercentage.round().toString(),
//             onChanged: (value) {
//               setState(() {
//                 _localOverallCompletionPercentage = value.round();
//               });
//             },
//             onChangeEnd: (value) {
//               _updateDummyActivityProgressOnBackend(value.round()); // Call the dummy update
//             },
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _isLoading ? null : () => _updateDummyActivityProgressOnBackend(_localOverallCompletionPercentage),
//             icon: const Icon(AntDesign.upload, color: Colors.white),
//             label: Text(
//               _isLoading ? 'Đang cập nhật...' : 'Cập nhật tiến độ hoạt động mẫu',
//               style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 16 : 18),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF50E3C2),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//               padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 25, vertical: isSmallScreen ? 10 : 12),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           // Hiển thị thông tin tiến độ tổng thể
//           if (_overallProgress != null)
//             Text(
//               'Trạng thái tổng thể: ${_overallProgress!.status} - Cập nhật lần cuối: ${_overallProgress!.lastUpdated?.toLocal().toString().split('.')[0] ?? 'N/A'}',
//               style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.black54),
//               textAlign: TextAlign.center,
//             ),
//           const SizedBox(height: 10),
//           ElevatedButton.icon(
//             onPressed: _isLoading ? null : _loadOverallProgress, // Button to manually refresh overall progress
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             label: const Text(
//               'Tải lại tiến độ tổng thể',
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF4A90E2),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
