import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/flashcard.dart';
import '../../services/auth_service.dart';
import '../../services/flashcard_service.dart';
import '../../services/progress_service.dart'; // Import ProgressService
import '../../models/progress.dart'; // Import Progress models

class FlashcardsTab extends StatefulWidget {
  final Future<List<FlashcardResponse>> flashcardsFuture;
  final Function() updateProgress; // Callback now takes no arguments
  final int userId; // Required for progress update
  final int lessonId; // Required for progress update

  const FlashcardsTab({
    super.key,
    required this.flashcardsFuture,
    required this.updateProgress,
    required this.userId,
    required this.lessonId,
  });

  @override
  State<FlashcardsTab> createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends State<FlashcardsTab> {
  List<FlashcardResponse> _flashcards = [];
  bool _isLoading = true;
  String? _error;
  late FlashcardService _flashcardService;
  late ProgressService _progressService; // Declare ProgressService

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _flashcardService = FlashcardService(authService);
    _progressService = ProgressService(authService); // Initialize ProgressService
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    try {
      final data = await widget.flashcardsFuture;
      setState(() {
        _flashcards = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading flashcards: $e');
    }
  }

  Future<void> _markFlashcardAsKnown(int wordId, bool isKnown) async {
    try {
      // Create UserFlashcardRequest object
      final userFlashcardRequest = UserFlashcardRequest(
        userId: widget.userId,
        wordId: wordId,
        isKnown: isKnown,
      );

      // Update flashcard status by passing the UserFlashcardRequest object
      await _flashcardService.markFlashcard(userFlashcardRequest); // FIXED: Pass UserFlashcardRequest

      // Reload flashcards to reflect changes
      await _loadFlashcards();

      // Calculate new completion percentage for flashcards activity
      final knownFlashcards = _flashcards.where((f) => f.isKnown).length;
      final totalFlashcards = _flashcards.length;
      final completionPercentage = totalFlashcards == 0 ? 0 : (knownFlashcards / totalFlashcards * 100).round();

      // Update progress for FLASHCARDS activity
      final progressRequest = ProgressRequest(
        userId: widget.userId,
        lessonId: widget.lessonId,
        activityType: 'FLASHCARDS', // Specific activity type for flashcards
        status: completionPercentage == 100 ? 'COMPLETED' : 'IN_PROGRESS',
        completionPercentage: completionPercentage,
      );
      await _progressService.updateProgress(progressRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật flashcard. Tiến độ Flashcards: $completionPercentage%')),
      );
      widget.updateProgress(); // Notify parent to refresh overall lesson progress
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật flashcard: $e')),
      );
      debugPrint('Error marking flashcard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)));
    } else if (_error != null) {
      return Center(
        child: Text(
          'Lỗi khi tải flashcard: $_error',
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_flashcards.isEmpty) {
      return const Center(
        child: Text(
          'Không có flashcard nào cho bài học này.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _flashcards.length,
      itemBuilder: (context, index) {
        final flashcard = _flashcards[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flashcard.word,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  flashcard.meaning,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phát âm: ${flashcard.pronunciation}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    IconButton(
                      icon: Icon(
                        flashcard.isKnown ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: flashcard.isKnown ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _markFlashcardAsKnown(flashcard.wordId, !flashcard.isKnown),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
