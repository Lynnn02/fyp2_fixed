import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/module_button.dart';
import '../leaderboard/leaderboard_navigation.dart';
import 'module4_playScreen.dart';

class Module4Screen extends StatelessWidget {
  final String userId;
  final String userName;
  const Module4Screen({
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
        automaticallyImplyLeading: false, // Remove back button
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
              // Play Button
              ModuleButton(
                text: 'PLAY',
                backgroundColor: const Color(0xFF4CAF50), // Green
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => Module4PlayScreen(
                        userId: userId,
                        userName: userName,
                      ),
                    ),
                  );
                },
              ),
              // Leaderboard Button
              ModuleButton(
                text: 'LEADERBOARD',
                backgroundColor: const Color(0xFF2196F3), // Blue
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaderboardNavigation(
                        userId: userId,
                        userName: userName,
                        ageGroup: 4,
                      ),
                    ),
                  );
                },
              ),
              // Settings Button
              ModuleButton(
                text: 'SETTING',
                backgroundColor: const Color(0xFF9E9E9E), // Grey
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
