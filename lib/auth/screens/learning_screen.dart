import 'package:flutter/material.dart';
import 'package:flutter_auth_app/auth/screens/progress_tab.dart';
import 'package:flutter_auth_app/auth/screens/quizzes_tab.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

// Import các models và services cần thiết
import '../../models/lesson.dart';
import '../../models/enrollment.dart';
import '../../models/learning_material.dart';
import '../../models/quiz.dart';
import '../../models/flashcard.dart';
import '../../models/progress.dart';
import '../../services/auth_service.dart';
import '../../services/lesson_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/learning_material_service.dart';
import '../../services/quiz_service.dart';
import '../../services/flashcard_service.dart';
import '../../services/progress_service.dart';
import 'cart_screen.dart';
import 'learning_screen.dart';
import 'flashcards_tab.dart';
import 'materials.tab.dart';
import 'quiz_results_tab.dart';
import 'package:decimal/decimal.dart';
import 'package:collection/collection.dart'; // Thêm import này cho firstWhereOrNull

class LearningScreen extends StatefulWidget {
  final Lesson lesson;

  const LearningScreen({super.key, required this.lesson});

  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<LearningMaterial>> _materialsFuture;
  late Future<List<QuizResponse>> _quizzesFuture;
  late Future<List<FlashcardResponse>> _flashcardsFuture;
  late ProgressService _progressService;
  double _overallLessonProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final authService = Provider.of<AuthService>(context, listen: false);
    _progressService = ProgressService(authService);
    final learningMaterialService = LearningMaterialService(authService);
    final quizService = QuizService(authService);
    final flashcardService = FlashcardService(authService);

    final int? userId = authService.currentUser?.userId;

    _materialsFuture = learningMaterialService.getLearningMaterialsByLessonId(widget.lesson.lessonId);
    _quizzesFuture = quizService.getQuizzesByLessonId(widget.lesson.lessonId);
    _flashcardsFuture = userId != null
        ? flashcardService.getFlashcards(userId, widget.lesson.lessonId)
        : Future.value([]);

    if (userId != null) {
      _loadOverallLessonProgress(userId, widget.lesson.lessonId);
    }
  }

  Future<void> _loadOverallLessonProgress(int userId, int lessonId) async {
    try {
      final overallProgress = await _progressService.getOverallLessonProgress(userId, lessonId);
      setState(() {
        _overallLessonProgress = overallProgress.completionPercentage.toDouble();
      });
    } catch (e) {
      debugPrint('Error loading overall lesson progress: $e');
      setState(() {
        _overallLessonProgress = 0.0;
      });
    }
  }

  // Callback now takes no arguments
  void _handleOverallProgressUpdate() {
    final int? userId = Provider.of<AuthService>(context, listen: false).currentUser?.userId;
    if (userId != null) {
      _loadOverallLessonProgress(userId, widget.lesson.lessonId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final int? userId = authService.currentUser?.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lỗi truy cập', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF4A90E2),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Bạn cần đăng nhập để xem nội dung này. Vui lòng đăng nhập lại.',
              style: TextStyle(fontSize: 16, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.lesson.title} (${_overallLessonProgress.round()}%)',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(AntDesign.filetext1), text: 'Tài liệu'),
            Tab(icon: Icon(AntDesign.questioncircleo), text: 'Bài KT'),
            Tab(icon: Icon(AntDesign.book), text: 'Flashcard'),
            Tab(icon: Icon(AntDesign.barchart), text: 'Tiến độ'),
            Tab(icon: Icon(Icons.history), text: 'Kết quả'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFF50E3C2),
          isScrollable: true,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            MaterialsTab(
              materialsFuture: _materialsFuture,
              updateProgress: _handleOverallProgressUpdate,
              userId: userId,
              lessonId: widget.lesson.lessonId,
            ),
            QuizzesTab(
              quizzesFuture: _quizzesFuture,
              updateProgress: _handleOverallProgressUpdate,
              userId: userId,
              lessonId: widget.lesson.lessonId,
            ),
            FlashcardsTab(
              flashcardsFuture: _flashcardsFuture,
              updateProgress: _handleOverallProgressUpdate, // ADDED: updateProgress
              userId: userId,
              lessonId: widget.lesson.lessonId,
            ),
            ProgressTab(
              userId: userId,
              lessonId: widget.lesson.lessonId,
              updateOverallProgress: _handleOverallProgressUpdate,
            ),
            QuizResultsTab(
              userId: userId,
              updateProgress: _handleOverallProgressUpdate,
            ),
          ],
        ),
      ),
    );
  }
}
