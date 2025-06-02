import 'package:flutter/material.dart';
import 'admin_ui_style.dart';
import 'admin_app_bar.dart';

/// A shared scaffold for all admin screens that includes the app bar and bottom navigation
class AdminScaffold extends StatelessWidget {
  final String title;
  final int selectedIndex;
  final Function(int) onNavigate;
  final Widget body;
  final FloatingActionButton? floatingActionButton;

  const AdminScaffold({
    Key? key,
    required this.title,
    required this.selectedIndex,
    required this.onNavigate,
    required this.body,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobileView = isMobile(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AdminAppBar(
        title: title,
        selectedIndex: selectedIndex,
        onNavigate: onNavigate,
      ),
      // Add bottom navigation for mobile view
      bottomNavigationBar: isMobileView ? BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onNavigate,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Content',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ) : null,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
