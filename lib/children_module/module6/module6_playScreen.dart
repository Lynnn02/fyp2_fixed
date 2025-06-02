import 'package:flutter/material.dart';
import '../../widgets/module_button.dart';
import '../Game/gameSubjectSelection_screen.dart';

class Module6PlayScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const Module6PlayScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/rainbow.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content Column with Logo and Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/logo.png',
                width: 200,
              ),
              const SizedBox(height: 40),
              // Learn Button
              ModuleButton(
                text: 'LEARN',
                backgroundColor: const Color(0xFF9C27B0), // Purple
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/subjectSelection',
                    arguments: {
                      'moduleId': 6,
                      'userId': userId,
                      'userName': userName,
                    },
                  );
                },
              ),
              // Quiz Button
              ModuleButton(
                text: 'GAME',
                backgroundColor: const Color(0xFF9C27B0), // Purple
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameSubjectSelectionScreen(
                        moduleId: 6,
                        userId: userId,
                        userName: userName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
