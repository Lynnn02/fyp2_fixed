import 'package:flutter/material.dart';
import '../widgets/module_button.dart';
import 'parent_mode_screen.dart';
import 'profile_screen.dart';

class SettingScreen extends StatelessWidget {
  final String userId;
  
  const SettingScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 28),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ParentModeScreen(userId: userId),
              ),
            );
          },
        ),
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
          // Content Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Setting Text
              const Text(
                'SETTING',
                style: TextStyle(
                  fontFamily: 'ITEM',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Parent Mode Button
              ModuleButton(
                text: 'PARENT MODE',
                backgroundColor: const Color(0xFF9C27B0), // Purple
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentModeScreen(userId: userId),
                    ),
                  );
                },
              ),
              // Profile Button
              ModuleButton(
                text: 'PROFILE',
                backgroundColor: const Color(0xFF1976D2), // Blue
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(studentId: userId),
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
