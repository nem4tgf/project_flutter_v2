import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ListeningQuizScreen extends StatefulWidget {
  final String topicName;

  const ListeningQuizScreen({super.key, required this.topicName});

  @override
  State<ListeningQuizScreen> createState() => _ListeningQuizScreenState();
}

class _ListeningQuizScreenState extends State<ListeningQuizScreen> {
  late List<Question> questions;
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  int? selectedAnswerIndex;
  
  // Audio player instances
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    questions = quizData[widget.topicName] ?? [];
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    
    // Auto-load first audio if questions exist
    if (questions.isNotEmpty) {
      _loadAudio();
    }
  }

  void _setupAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _isPlaying = playerState.playing;
          _isLoading = playerState.processingState == ProcessingState.loading ||
                     playerState.processingState == ProcessingState.buffering;
        });
      }
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  Future<void> _loadAudio() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final question = questions[currentIndex];
      await _audioPlayer.setAsset(question.audioPath);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.seek(Duration.zero);
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  void checkAnswer(int index) {
    if (answered) return;

    setState(() {
      answered = true;
      selectedAnswerIndex = index;
      if (questions[currentIndex].correctAnswerIndex == index) {
        score++;
      }
    });
  }

  Future<void> nextQuestion() async {
    await _stopAudio();
    
    setState(() {
      currentIndex++;
      answered = false;
      selectedAnswerIndex = null;
      _position = Duration.zero;
    });

    if (currentIndex < questions.length) {
      await _loadAudio();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildAudioPlayer() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isLoading ? null : _playPause,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _isLoading ? null : _stopAudio,
                  icon: const Icon(Icons.stop, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.green,
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: Colors.green,
                    overlayColor: Colors.green.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                    onChanged: (value) async {
                      final position = Duration(
                        milliseconds: (value * _duration.inMilliseconds).round(),
                      );
                      await _audioPlayer.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName),
          backgroundColor: Colors.green[100]!,
        ),
        body: const Center(
          child: Text('No questions available for this topic.'),
        ),
      );
    }

    if (currentIndex >= questions.length) {
      String message;
      double percent = score / questions.length;

      if (percent >= 0.8) {
        message = 'Excellent! You are mastering English listening skills.';
      } else if (percent >= 0.5) {
        message = 'Good job! Keep practicing to improve more.';
      } else {
        message = 'Keep trying! Practice makes perfect.';
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName),
          backgroundColor: Colors.green[100]!,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.headset, size: 120, color: Colors.green.shade700),
                const SizedBox(height: 24),
                Text('Quiz Completed!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 16),
                Text('Your score: $score / ${questions.length}',
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 16),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Topics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100]!,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName),
        backgroundColor: Colors.green[100]!,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              backgroundColor: Colors.green.shade100,
              color: Colors.green.shade700,
              minHeight: 8,
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              child: Column(
                key: ValueKey<int>(currentIndex),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentIndex + 1} of ${questions.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  
                  // Audio Player Widget
                  _buildAudioPlayer(),
                  
                  const SizedBox(height: 20),
                  Text(
                    question.question,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(
                    question.options.length,
                    (index) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: answered
                          ? (index == question.correctAnswerIndex
                              ? Colors.green[100]
                              : (index == selectedAnswerIndex
                                  ? Colors.red[100]
                                  : Colors.white))
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: answered
                              ? (index == question.correctAnswerIndex
                                  ? Colors.green
                                  : (index == selectedAnswerIndex
                                      ? Colors.red
                                      : Colors.grey.shade300))
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          question.options[index],
                          style: const TextStyle(fontSize: 18),
                        ),
                        onTap: () => checkAnswer(index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (answered)
              Center(
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(currentIndex == questions.length - 1 ? 'Finish' : 'Next'),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String audioPath; // New field for audio file path

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.audioPath,
  });
}

final Map<String, List<Question>> quizData = {
  'Listening Practice Test 1': [
    Question(
      question: 'What did Jack do over the weekend?',
      options: [
        'He went hiking with friends.',
        'He stayed home and watched movies.',
        'He visited his grandparents.',
        'He attended a concert.'
        
      ],
      correctAnswerIndex: 0,
      audioPath: 'audio/ques1.mp3',
    ),
    Question(
      question: 'What is the name of the song that the audio played?',
      options: [
        'Rolling in the Deep',
        'Never Gonna Give You Up',
        'Shape of You',
        'Uptown Funk'
        
      ],
      correctAnswerIndex: 1,
      audioPath: 'audio/rolled.mp3',
    ),
    Question(
      question: 'What is implied about the meeting time?',
      options: [
        'It is at 10 AM',
        'It has been postponed',
        'It will be cancelled',
        'It is early in the morning'
      ],
      correctAnswerIndex: 1,
      audioPath: 'assets/audio/test1_q3.mp3',
    ),
    Question(
      question: 'What emotion does the speaker express?',
      options: [
        'Happiness',
        'Frustration',
        'Excitement',
        'Confusion'
      ],
      correctAnswerIndex: 2,
      audioPath: 'assets/audio/test1_q4.mp3',
    ),
    Question(
      question: 'What should listeners do if they dont understand a word?',
      options: [
        'Ignore it',
        'Look it up later',
        'Ask the speaker',
        'Guess the meaning'
      ],
      correctAnswerIndex: 1,
      audioPath: 'assets/audio/test1_q5.mp3',
    ),
  ],
  'Listening Practice Test 2': [
    Question(
      question: 'Where does the conversation take place?',
      options: [
        'At a restaurant',
        'In a library',
        'At a train station',
        'In a park'
      ],
      correctAnswerIndex: 2,
      audioPath: 'assets/audio/test2_q1.mp3',
    ),
    Question(
      question: 'What is the woman planning to do next?',
      options: [
        'Buy a ticket',
        'Call a friend',
        'Catch a train',
        'Go shopping'
      ],
      correctAnswerIndex: 0,
      audioPath: 'assets/audio/test2_q2.mp3',
    ),
    Question(
      question: 'Why is the man upset?',
      options: [
        'He missed the train',
        'He lost his wallet',
        'He is late for work',
        'He forgot his phone'
      ],
      correctAnswerIndex: 1,
      audioPath: 'assets/audio/test2_q3.mp3',
    ),
    Question(
      question: 'What does the phrase "on the house" mean?',
      options: [
        'Free of charge',
        'At the top floor',
        'Provided by the owner',
        'With extra service'
      ],
      correctAnswerIndex: 0,
      audioPath: 'assets/audio/test2_q4.mp3',
    ),
    Question(
      question: 'What advice does the speaker give about studying?',
      options: [
        'Study in groups',
        'Listen carefully',
        'Take frequent breaks',
        'Use flashcards'
      ],
      correctAnswerIndex: 2,
      audioPath: 'assets/audio/test2_q5.mp3',
    ),
  ],
  'Academic Listening Sample': [
    Question(
      question: 'What is the purpose of the lecture?',
      options: [
        'To introduce new research',
        'To review a book',
        'To explain a theory',
        'To discuss a case study'
      ],
      correctAnswerIndex: 2,
      audioPath: 'assets/audio/academic_q1.mp3',
    ),
    Question(
      question: 'What does the speaker say about the experiment?',
      options: [
        'It was unsuccessful',
        'It proved the hypothesis',
        'It needs more data',
        'It was inconclusive'
      ],
      correctAnswerIndex: 1,
      audioPath: 'assets/audio/academic_q2.mp3',
    ),
    Question(
      question: 'What is the main focus of the study?',
      options: [
        'Climate change',
        'Language acquisition',
        'Economic trends',
        'Psychological effects'
      ],
      correctAnswerIndex: 3,
      audioPath: 'assets/audio/academic_q3.mp3',
    ),
  ],
  'General Training Listening Sample': [
    Question(
      question: 'What is the correct response to the question: "Can you help me?"',
      options: [
        'No, I cant.',
        'Yes, of course.',
        'Maybe later.',
        'I dont know.'
      ],
      correctAnswerIndex: 1,
      audioPath: 'assets/audio/general_q1.mp3',
    ),
    Question(
      question: 'What is the speakers tone in the message?',
      options: [
        'Formal',
        'Friendly',
        'Angry',
        'Confused'
      ],
      correctAnswerIndex: 1,
      audioPath: 'assets/audio/general_q2.mp3',
    ),
    Question(
      question: 'Where is the speaker going?',
      options: [
        'To the supermarket',
        'To the post office',
        'To the bank',
        'To the library'
      ],
      correctAnswerIndex: 0,
      audioPath: 'assets/audio/general_q3.mp3',
    ),
  ],
};