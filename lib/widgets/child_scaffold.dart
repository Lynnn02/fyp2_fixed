import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A shared scaffold for all children's screens that includes a bottom navigation bar
/// and sign-out functionality
class ChildScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int selectedIndex;
  final bool showAppBar;
  final Color? appBarColor;
  final List<Widget>? appBarActions;
  final bool extendBodyBehindAppBar;
  final Widget? floatingActionButton;
  final Widget? backgroundImage;
  final Function(int) onNavigate;

  const ChildScaffold({
    Key? key,
    required this.title,
    required this.body,
    required this.selectedIndex,
    required this.onNavigate,
    this.showAppBar = true,
    this.appBarColor,
    this.appBarActions,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButton,
    this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'ITEM',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor ?? Colors.transparent,
        elevation: appBarColor != null ? 4 : 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Sign out button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: () {
              _showSignOutDialog(context);
            },
          ),
          ...(appBarActions ?? []),
        ],
      ) : null,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Background image if provided
          if (backgroundImage != null) backgroundImage!,
          
          // Main content
          body,
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Build the bottom navigation bar for children
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onNavigate,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'ITEM',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'ITEM',
          fontSize: 12,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Awards',
          ),
        ],
      ),
    );
  }

  // Show sign out confirmation dialog
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 10),
            const Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('SIGN OUT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              // Clear SharedPreferences user data
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('currentUserId');
              await prefs.remove('currentUsername');
              await prefs.remove('currentUserEmail');
              await prefs.remove('currentUserDisplayName');
              await prefs.setBool('isUserLoggedIn', false);
              
              print('Cleared user credentials from SharedPreferences during sign out');
              
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Close the dialog
              
              // Navigate to login screen and clear navigation history
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', 
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
