import 'package:flutter/material.dart';

class WritingQuizScreen extends StatefulWidget {
  final String topicName;

  const WritingQuizScreen({super.key, required this.topicName});

  @override
  State<WritingQuizScreen> createState() => _WritingQuizScreenState();
}

class _WritingQuizScreenState extends State<WritingQuizScreen> {
  late List<Question> questions;
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  String userAnswer = '';
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    questions = quizData[widget.topicName] ?? [];
  }

  void checkAnswer() {
    if (answered) return;
    final correct = questions[currentIndex].correctAnswer.trim().toLowerCase();
    final input = userAnswer.trim().toLowerCase();
    setState(() {
      answered = true;
      isCorrect = input == correct;
      if (isCorrect) score++;
    });
  }

  void nextQuestion() {
    setState(() {
      currentIndex++;
      answered = false;
      userAnswer = '';
      isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName),
          backgroundColor: Colors.deepOrange[200]!,
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
        message = 'Excellent! You are mastering English writing skills.';
      } else if (percent >= 0.5) {
        message = 'Good job! Keep practicing to improve more.';
      } else {
        message = 'Keep trying! Practice makes perfect.';
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName),
          backgroundColor: Colors.deepOrange[200]!,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_document, size: 120, color: Colors.deepOrange.shade700),
                const SizedBox(height: 24),
                Text('Quiz Completed!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.deepOrange[200]!, fontWeight: FontWeight.bold)),
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
                    backgroundColor: Colors.deepOrange[200]!,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
        backgroundColor: Colors.deepOrange[200]!,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              backgroundColor: Colors.orange.shade100,
              color: Colors.deepOrange.shade700,
              minHeight: 8,
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Column(
                key: ValueKey<int>(currentIndex),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentIndex + 1} of ${questions.length}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    question.question,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter your answer',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      userAnswer = value;
                    },
                    enabled: !answered,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: checkAnswer,
                    child: const Text('Check Answer'),
                  ),
                  if (answered)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        isCorrect
                            ? 'Correct!'
                            : 'Incorrect. Correct answer: ${question.correctAnswer}',
                        style: TextStyle(
                          fontSize: 18,
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
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
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
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
  final String correctAnswer;

  Question({
    required this.question,
    required this.correctAnswer,
  });
}

final Map<String, List<Question>> quizData = {
  'Writing Task 1: Describe a Graph': [
    Question(
      question: 'What is the best way to start a report describing a graph?',
      correctAnswer: 'By a Pie chart',
    ),
    Question(
      question: 'Which tense is most commonly used in describing graphs?',
      correctAnswer: 'Present tense',
    ),
    Question(
      question: 'What should you include in the conclusion of a graph description?',
      correctAnswer: 'Summary of main trends',
    ),
    Question(
      question: 'Which phrase is appropriate to compare data?',
      correctAnswer: 'All of the above',
    ),
    Question(
      question: 'What is the main purpose of Task 1 in IELTS Writing?',
      correctAnswer: 'To describe visual information',
    ),
  ],

// Add more topics and questions as needed
  'Writing Task 2: Argumentative Essay': [
    Question(
      question: 'What is the main purpose of an argumentative essay?',
      correctAnswer: 'To present a clear argument and support it with evidence',
    ),
    Question(
      question: 'What structure should an argumentative essay follow?',
      correctAnswer: 'Introduction, body paragraphs, conclusion',
    ),
    Question(
      question: 'What is a counterargument?',
      correctAnswer: 'An opposing viewpoint to your argument',
    ),
    Question(
      question: 'How should you address counterarguments in your essay?',
      correctAnswer: 'Acknowledge and refute them',
    ),
    Question(
      question: 'What is the importance of a strong thesis statement?',
      correctAnswer: 'It guides the direction of your essay',
    ),
  ],

  'Writing Task 3: Problem Solution Essay': [
    Question(
      question: 'What is the main focus of a problem solution essay?',
      correctAnswer: 'To identify a problem and propose solutions',
    ),
    Question(
      question: 'What should the introduction include?',
      correctAnswer: 'A clear statement of the problem',
    ),
    Question(
      question: 'How many solutions should you propose?',
      correctAnswer: 'At least two',
    ),
    Question(
      question: 'What is important in the conclusion?',
      correctAnswer: 'Summarize the problem and solutions',
    ),
    Question(
      question: 'What type of language should you use in this essay?',
      correctAnswer: 'Formal and objective',
    ),
  ],
  // Add more topics and questions as needed


  'Writing Task 4: Opinion Essay': [
    Question(
      question: 'What is the main purpose of an opinion essay?',
      correctAnswer: 'To express your viewpoint on a topic',
    ),
    Question(
      question: 'What should the introduction include?',
      correctAnswer: 'Your opinion and a brief outline of your arguments',
    ),
    Question(
      question: 'How many body paragraphs should you have?',
      correctAnswer: 'At least two, each presenting a different argument',
    ),
    Question(
      question: 'What is important in the conclusion?',
      correctAnswer: 'Restate your opinion and summarize your arguments',
    ),
    Question(
      question: 'What type of language should you use in this essay?',
      correctAnswer: 'Persuasive and clear',
    ),
  ],
};