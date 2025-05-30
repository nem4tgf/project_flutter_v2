import 'package:flutter/material.dart';
import 'listening_quiz_screen.dart';

class ListeningListScreen extends StatelessWidget {
  const ListeningListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listeningTopics = [
      'Listening Practice Test 1',
      'Listening Practice Test 2',
      'Academic Listening Sample',
      'General Training Listening Sample',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening Practice Tests'),
        backgroundColor: Colors.green[100]!,
        centerTitle: true,
        elevation: 6,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: listeningTopics.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  splashColor: Colors.green.withOpacity(0.2),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ListeningQuizScreen(topicName: listeningTopics[index]),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green[100]!,
                          child: const Icon(Icons.headphones,
                              size: 32, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            listeningTopics[index],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.green),
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
