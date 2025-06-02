import 'package:flutter/material.dart';
import '../../widgets/module_button.dart';
import '../../widgets/child_scaffold.dart';
import '../leaderboard/leaderboard_navigation.dart';
import 'module5_playScreen.dart';

class Module5Screen extends StatelessWidget {
  final String userId;
  final String userName;

  const Module5Screen({
    super.key,
    required this.userId,
    required this.userName,
  });

  void _handleNavigation(int index, BuildContext context) {
    switch (index) {
      case 0: // Home - already on this screen
        break;
      case 1: // Games
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Module5PlayScreen(
              userId: userId,
              userName: userName,
            ),
          ),
        );
        break;
      case 2: // Learn
        Navigator.pushNamed(context, '/module5Learn');
        break;
      case 3: // Leaderboard
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderboardNavigation(
              userId: userId,
              userName: userName,
              ageGroup: 5,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Background image widget
    final backgroundImage = Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/rainbow.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
    
    // Main content
    final content = Center(
      child: Column(
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
                  builder: (context) => Module5PlayScreen(
                    userId: userId,
                    userName: userName,
                  ),
                ),
              );
            },
          ),
          // Learn Button
          ModuleButton(
            text: 'LEARN',
            backgroundColor: const Color(0xFF2196F3), // Blue
            onPressed: () {
              Navigator.pushNamed(context, '/module5Learn');
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
                    ageGroup: 5,
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
    );
    
    return ChildScaffold(
      title: 'Home',
      selectedIndex: 0, // Home tab is selected
      onNavigate: (index) => _handleNavigation(index, context),
      showAppBar: false, // Hide app bar to show full background
      extendBodyBehindAppBar: true,
      backgroundImage: backgroundImage,
      body: content,
    );
  }
}
