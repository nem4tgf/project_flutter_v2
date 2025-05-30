import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    questions = quizData[widget.topicName] ?? [];
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

  void nextQuestion() {
    setState(() {
      currentIndex++;
      answered = false;
      selectedAnswerIndex = null;
    });
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

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

final Map<String, List<Question>> quizData = {
  'Listening Practice Test 1': [
    Question(
      question: 'What is the main topic discussed in the audio clip?',
      options: [
        'The benefits of exercise',
        'How to cook pasta',
        'The history of the internet',
        'Traveling tips for Europe'
      ],
      correctAnswerIndex: 0,
    ),
    Question(
      question: 'What does the speaker suggest doing to stay healthy?',
      options: [
        'Eat more sugar',
        'Exercise regularly',
        'Watch more TV',
        'Sleep less'
      ],
      correctAnswerIndex: 1,
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
    ),
    Question(
      question: 'What should listeners do if they don’t understand a word?',
      options: [
        'Ignore it',
        'Look it up later',
        'Ask the speaker',
        'Guess the meaning'
      ],
      correctAnswerIndex: 1,
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
    ),
    Question(
      question: 'What does the phrase “on the house” mean?',
      options: [
        'Free of charge',
        'At the top floor',
        'Provided by the owner',
        'With extra service'
      ],
      correctAnswerIndex: 0,
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
    ),
  ],
  'General Training Listening Sample': [
    Question(
      question: 'What is the correct response to the question: "Can you help me?"',
      options: [
        'No, I can’t.',
        'Yes, of course.',
        'Maybe later.',
        'I don’t know.'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      question: 'What is the speaker’s tone in the message?',
      options: [
        'Formal',
        'Friendly',
        'Angry',
        'Confused'
      ],
      correctAnswerIndex: 1,
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
    ),
  ],
};
