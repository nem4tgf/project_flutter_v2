import 'package:flutter/material.dart';

class ReadingQuizScreen extends StatefulWidget {
  final String topicName;

  const ReadingQuizScreen({super.key, required this.topicName});

  @override
  State<ReadingQuizScreen> createState() => _ReadingQuizScreenState();
}

class _ReadingQuizScreenState extends State<ReadingQuizScreen> {
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
          backgroundColor: Colors.blue[100]!,
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
        message = 'Excellent! You are mastering English reading skills.';
      } else if (percent >= 0.5) {
        message = 'Good job! Keep practicing to improve more.';
      } else {
        message = 'Keep trying! Practice makes perfect.';
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.topicName),
          backgroundColor: Colors.blue[100]!,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 120, color: Colors.amber.shade700),
                const SizedBox(height: 24),
                Text('Quiz Completed!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.blue[100]!, fontWeight: FontWeight.bold)),
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
                    backgroundColor: Colors.blue[100]!,
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
        backgroundColor: Colors.blue[100]!,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              backgroundColor: Colors.indigo.shade100,
              color: Colors.indigo.shade700,
              minHeight: 8,
            ),
            const SizedBox(height: 24),
            // AnimatedSwitcher để chuyển câu hỏi mượt mà
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
                key: ValueKey<int>(currentIndex), // Khóa để AnimatedSwitcher nhận dạng widget mới
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentIndex + 1} of ${questions.length}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo),
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
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 36),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(currentIndex == questions.length - 1
                      ? 'Finish'
                      : 'Next'),
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

// Bộ câu hỏi mẫu (giữ nguyên như bạn đã cung cấp)
final Map<String, List<Question>> quizData = {
  'Reading Practice Test 1': [
    Question(
      question:
          'Which sentence correctly uses the subjunctive mood?',
      options: [
        'If I was you, I would study harder.',
        'If I were you, I would study harder.',
        'If I am you, I would study harder.',
        'If I be you, I would study harder.'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'What does the phrase "break the ice" mean in a conversation?',
      options: [
        'To start a conversation and make people feel more comfortable',
        'To shatter ice physically',
        'To cause a conflict',
        'To make things colder'
      ],
      correctAnswerIndex: 0,
    ),
    Question(
      question:
          'Choose the correct synonym for "ubiquitous":',
      options: ['Rare', 'Everywhere', 'Temporary', 'Dangerous'],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'Identify the type of clause in the sentence: "Although it was raining, we went out."',
      options: ['Independent clause', 'Dependent clause', 'Relative clause', 'Noun clause'],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'What is the best definition of "cognizant"?',
      options: [
        'Unaware',
        'Aware or informed',
        'Confused',
        'Excited'
      ],
      correctAnswerIndex: 1,
    ),
  ],
  'Reading Practice Test 2': [
    Question(
      question:
          'What is the passive voice of the sentence: "They will finish the project tomorrow"?',
      options: [
        'The project will be finished by them tomorrow',
        'They will be finished by the project tomorrow',
        'The project will finish tomorrow',
        'Will the project finish tomorrow?'
      ],
      correctAnswerIndex: 0,
    ),
    Question(
      question:
          'Which sentence uses the correct conditional form?',
      options: [
        'If he will come, we will start.',
        'If he comes, we will start.',
        'If he came, we will start.',
        'If he come, we will start.'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'What does the idiom "once in a blue moon" mean?',
      options: [
        'Very often',
        'Rarely',
        'Immediately',
        'Never'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'Select the word that is an antonym of "benevolent":',
      options: ['Kind', 'Cruel', 'Helpful', 'Generous'],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'Identify the part of speech of the underlined word: "She *quickly* ran to the store."',
      options: ['Noun', 'Verb', 'Adverb', 'Adjective'],
      correctAnswerIndex: 2,
    ),
  ],
  'Academic Reading Sample': [
    Question(
      question:
          'What is the main purpose of an academic abstract?',
      options: [
        'To provide detailed data',
        'To summarize the key points',
        'To give background information',
        'To list references'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'In academic writing, which voice is usually preferred?',
      options: [
        'Passive voice',
        'Active voice',
        'Imperative voice',
        'Interrogative voice'
      ],
      correctAnswerIndex: 0,
    ),
    Question(
      question:
          'What is a “peer-reviewed” journal?',
      options: [
        'A journal reviewed by experts before publication',
        'A journal edited by students',
        'A journal with advertisements',
        'A journal available online only'
      ],
      correctAnswerIndex: 0,
    ),
    Question(
      question:
          'Which citation style uses “et al.” for multiple authors?',
      options: [
        'APA',
        'MLA',
        'Chicago',
        'Harvard'
      ],
      correctAnswerIndex: 0,
    ),
  ],
  'General Training Reading Sample': [
    Question(
      question:
          'What is the main difference between formal and informal writing?',
      options: [
        'Formal writing uses slang; informal does not',
        'Formal writing is structured and uses polite language; informal is casual',
        'Informal writing always uses complex sentences',
        'Formal writing is only used in emails'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'Which sentence is an example of a polite request?',
      options: [
        'Give me the report now.',
        'Can you please send me the report?',
        'Send me the report ASAP.',
        'I want the report.'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      question:
          'In a formal letter, how should you address the recipient?',
      options: [
        'Hey there!',
        'Dear Sir or Madam,',
        'Yo!',
        'Hi!'
      ],
      correctAnswerIndex: 1,
    ),
  ],
};
