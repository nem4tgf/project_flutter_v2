import 'package:flutter/material.dart';

import 'writing_quiz_screen.dart';

class WritingListScreen extends StatelessWidget {
  const WritingListScreen({super.key});

  final List<String> writingTopics = const [
    'Writing Task 1: Describe a Graph',
    'Writing Task 2: Argumentative Essay',
    'Writing Task 3: Problem Solution Essay',
    'Writing Task 4: Opinion Essay',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Practice Tests'),
        backgroundColor: Colors.orange[200]!,
        centerTitle: true,
        elevation: 6,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: writingTopics.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  splashColor: Colors.orange.withOpacity(0.2),
                  onTap: () {
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${writingTopics[index]}')),
                    );

                    
                   
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            WritingQuizScreen(topicName: writingTopics[index]),
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
                          backgroundColor: Colors.orange[200]!,
                          child: const Icon(Icons.edit, size: 32, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            writingTopics[index],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
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
