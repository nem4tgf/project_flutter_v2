import 'package:flutter/material.dart';
import 'reading_quiz_screen.dart';

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final readingTopics = [
      'Reading Practice Test 1',
      'Reading Practice Test 2',
      'Academic Reading Sample',
      'General Training Reading Sample',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Practice Tests'),
        backgroundColor: Colors.blue[100]!,
        centerTitle: true,
        elevation: 6,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: readingTopics.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  splashColor: Colors.indigo.withOpacity(0.2),
                  onTap: () {
                    Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        ReadingQuizScreen(topicName: readingTopics[index]),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  ),
);

                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[100]!,
                          child: const Icon(Icons.menu_book_rounded,
                              size: 32, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            readingTopics[index],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.indigo),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
