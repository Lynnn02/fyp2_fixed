import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/module_button.dart';
import '../leaderboard/leaderboard_navigation.dart';
import 'module6_playScreen.dart';

class Module6Screen extends StatelessWidget {
  final String userId;
  final String userName;

  const Module6Screen({
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ) ?? false;
              
              if (shouldLogout) {
                await FirebaseAuth.instance.signOut();
                // Navigate to login screen and remove all previous routes
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false,
                );
              }
            },
          ),
        ],
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
                      builder: (context) => Module6PlayScreen(
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
                backgroundColor: const Color(0xFFFFB74D), // Orange
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaderboardNavigation(
                        userId: userId,
                        userName: userName,
                        ageGroup: 6,
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
