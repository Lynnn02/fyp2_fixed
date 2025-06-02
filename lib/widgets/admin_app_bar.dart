import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_ui_style.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int selectedIndex;
  final Function(int) onNavigate;

  const AdminAppBar({
    Key? key,
    required this.title,
    required this.selectedIndex,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobileView = isMobile(context);
    
    return AppBar(
      automaticallyImplyLeading: false, // Remove back button
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          // Logo or icon for mobile
          if (isMobileView)
            Container(
              padding: const EdgeInsets.only(right: 8),
              child: const Icon(
                Icons.school,
                color: primaryColor,
                size: 24,
              ),
            ),
          // Title
          Text(
            title,
            style: TextStyle(
              color: Colors.black, 
              fontSize: isMobileView ? 16 : 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          Spacer(), // Push everything else to the right
        ],
      ),
      actions: [
        // Only show navigation items on non-mobile screens
        if (!isMobileView)
          Container(
            padding: const EdgeInsets.only(right: 40),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavItem(context, 0, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(context, 1, Icons.people_outlined, 'Users'),
                _buildNavItem(context, 2, Icons.library_books_outlined, 'Content'),
                _buildNavItem(context, 3, Icons.analytics_outlined, 'Analytics'),
              ],
            ),
          ),
        // Removed notification icon as requested
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () async {
            // Show confirmation dialog before signing out
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context); // Close the dialog
                      
                      // Navigate to login screen and clear navigation history
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login', 
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text('SIGN OUT'),
                  ),
                ],
              ),
            );
          },
          color: Colors.black,
          iconSize: isMobileView ? 20 : 24,
        ),
      ],
      toolbarHeight: 60,
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onNavigate(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blue, width: 3.0)))
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black54,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
