import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/admin_ui_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_app_bar.dart';
import '../widgets/admin_scaffold.dart';
import 'user_management/user_list_screen.dart';
import 'analytic/new_analytic_screen.dart';
import 'content_management/content_management_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getOverviewStats() async {
    try {
      // Get all subjects
      final subjectsSnapshot = await FirebaseFirestore.instance.collection('subjects').get();
      final subjects = subjectsSnapshot.docs;
      
      // Count total chapters across all subjects and count chapters with games
      int totalChapters = 0;
      int chaptersWithGames = 0;
      
      for (var subject in subjects) {
        final data = subject.data();
        final chapters = data['chapters'] as List<dynamic>? ?? [];
        totalChapters += chapters.length;
        
        // Count chapters that have associated games
        for (var chapter in chapters) {
          if (chapter is Map<String, dynamic> && chapter['gameId'] != null) {
            chaptersWithGames++;
          }
        }
      }
      
      // Count subjects by module
      int module4Subjects = 0;
      int module5Subjects = 0;
      int module6Subjects = 0;
      
      for (var subject in subjects) {
        final data = subject.data();
        final moduleId = data['moduleId'] as int? ?? 0;
        
        if (moduleId == 4) module4Subjects++;
        else if (moduleId == 5) module5Subjects++;
        else if (moduleId == 6) module6Subjects++;
      }
      
      // Get total games from games collection for reference
      final games = await FirebaseFirestore.instance.collection('games').get();
      
      return {
        'subjects': subjects.length,
        'module4Subjects': module4Subjects,
        'module5Subjects': module5Subjects,
        'module6Subjects': module6Subjects,
        'chapters': totalChapters,
        'games': chaptersWithGames, // Use count of chapters with games instead of games collection size
      };
    } catch (e) {
      debugPrint('Error getting overview stats: $e');
      return {
        'subjects': 0,
        'module4Subjects': 0,
        'module5Subjects': 0,
        'module6Subjects': 0,
        'chapters': 0,
        'games': 0,
      };
    }
  }

  void _navigateToContentManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContentManagementScreen(),
      ),
    );
  }

  void _navigateToUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserListScreen(),
      ),
    );
  }

  void _navigateToAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticScreen(
          selectedIndex: 3, // Analytics is typically the 4th tab (index 3)
          onNavigate: _handleNavigation,
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Dashboard
        // Already on dashboard, no navigation needed
        break;
      case 1: // Users
        _navigateToUserManagement();
        break;
      case 2: // Content
        _navigateToContentManagement();
        break;
      case 3: // Analytics
        _navigateToAnalytics();
        break;
    }
  }
  


  void _navigateToModules() {
    // TODO: Navigate to modules screen
  }

  void _navigateToGames() {
    // TODO: Navigate to games screen
  }

  void _navigateToQuizzes() {
    // TODO: Navigate to quizzes screen
  }
  
  // Removed _navigateToFlashcardTest method - flashcards are now created only through the content page

  @override
  Widget build(BuildContext context) {
    final isDesktopView = isDesktop(context);
    final isTabletView = isTablet(context);
    final isMobileView = isMobile(context);

    // Get the appropriate title based on selected index
    final String title = _selectedIndex == 0 ? 'Admin Dashboard' : 
                         _selectedIndex == 1 ? 'User Management' :
                         _selectedIndex == 2 ? 'Content Management' : 'Analytics';
    
    // Create floating action button if needed
    final FloatingActionButton? fab = isMobileView && _selectedIndex == 2 ? 
      FloatingActionButton(
        onPressed: () {
          // Add new content action
          _navigateToContentManagement();
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ) : null;
    
    return AdminScaffold(
      title: title,
      selectedIndex: _selectedIndex,
      onNavigate: _handleNavigation,
      floatingActionButton: fab,
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktopView ? kSpacingLarge : kSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  if (!isDesktopView) ...[
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: kSpacingSmall),
                  ],

                  // Overview Section with more mobile-friendly title
                  sectionHeader(
                    title: 'Overview',
                    subtitle: isMobileView ? null : 'Quick stats about your learning content',
                  ),
                  const SizedBox(height: kSpacing),

                  FutureBuilder<Map<String, dynamic>>(
                    future: getOverviewStats(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final stats = snapshot.data!;
                      
                      if (isDesktopView || isTabletView) {
                        // Full-width row layout for desktop and tablet
                        return Row(
                          children: [
                            Expanded(
                              child: overviewStatsCard(
                                title: 'Subjects',
                                value: stats['subjects'].toString(),
                                icon: Icons.subject,
                                color: primaryColor,
                                subtitle: 'Age 4: ${stats["module4Subjects"]}, Age 5: ${stats["module5Subjects"]}, Age 6: ${stats["module6Subjects"]}',
                                onTap: () => _navigateToContentManagement(),
                              ),
                            ),
                            const SizedBox(width: kSpacing),
                            Expanded(
                              child: overviewStatsCard(
                                title: 'Chapters',
                                value: stats['chapters'].toString(),
                                icon: Icons.library_books,
                                color: successColor,
                                subtitle: 'Total chapters across all subjects',
                                onTap: () => _navigateToContentManagement(),
                              ),
                            ),
                            const SizedBox(width: kSpacing),
                            Expanded(
                              child: overviewStatsCard(
                                title: 'Games',
                                value: stats['games'].toString(),
                                icon: Icons.games,
                                color: warningColor,
                                subtitle: 'View all games',
                                onTap: _navigateToGames,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Enhanced mobile layout with grid for better space usage
                        return Column(
                          children: [
                            // First row of stats in a grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMobileStatsCard(
                                    title: 'Subjects',
                                    value: stats['subjects'].toString(),
                                    icon: Icons.subject,
                                    color: primaryColor,
                                    onTap: () => _navigateToContentManagement(),
                                  ),
                                ),
                                const SizedBox(width: kSpacingSmall),
                                Expanded(
                                  child: _buildMobileStatsCard(
                                    title: 'Chapters',
                                    value: stats['chapters'].toString(),
                                    icon: Icons.library_books,
                                    color: successColor,
                                    onTap: () => _navigateToContentManagement(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: kSpacingSmall),
                            // Single card for games instead of a row with two cards
                            _buildMobileStatsCard(
                              title: 'Total Content',
                              value: '${stats['chapters'] + stats['games']}',
                              icon: Icons.content_copy,
                              color: warningColor,
                              onTap: _navigateToContentManagement,
                            ),
                            
                            // Age breakdown card
                            const SizedBox(height: kSpacing),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.pie_chart, color: primaryColor),
                                      const SizedBox(width: 8),
                                      const Text('Age Breakdown', 
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildAgeStatColumn('Age 4', stats["module4Subjects"].toString(), Colors.blue),
                                      _buildAgeStatColumn('Age 5', stats["module5Subjects"].toString(), Colors.green),
                                      _buildAgeStatColumn('Age 6', stats["module6Subjects"].toString(), Colors.orange),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: kSpacingLarge),

// Quick Links Section - simplified for mobile
                  sectionHeader(
                    title: 'Quick Links',
                    subtitle: isMobileView ? null : 'Manage your content and users',
                  ),
                  const SizedBox(height: kSpacing),

                  if (isDesktopView || isTabletView)
                    Row(
                      children: [
                        Expanded(
                          child: quickLinkCard(
                            title: 'User Management',
                            subtitle: 'Manage users and track progress',
                            icon: Icons.people,
                            iconColor: primaryColor,
                            onTap: _navigateToUserManagement,
                          ),
                        ),
                        const SizedBox(width: kSpacing),
                        Expanded(
                          child: quickLinkCard(
                            title: 'Content Management',
                            subtitle: 'Manage subjects, chapters, and content',
                            icon: Icons.library_books,
                            iconColor: successColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ContentManagementScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: kSpacing),
                        Expanded(
                          child: quickLinkCard(
                            title: 'Analytics',
                            subtitle: 'View student performance and stats',
                            icon: Icons.analytics,
                            iconColor: Colors.purple,
                            onTap: _navigateToAnalytics,
                          ),
                        ),
                      ],
                    ),
                  if (MediaQuery.of(context).size.width < 600)
                    Column(
                      children: [
                        // Grid layout for quick links on mobile
                        Row(
                          children: [
                            Expanded(
                              child: _buildMobileQuickLinkCard(
                                title: 'Users',
                                icon: Icons.people,
                                iconColor: primaryColor,
                                onTap: _navigateToUserManagement,
                              ),
                            ),
                            const SizedBox(width: kSpacingSmall),
                            Expanded(
                              child: _buildMobileQuickLinkCard(
                                title: 'Content',
                                icon: Icons.library_books,
                                iconColor: successColor,
                                onTap: _navigateToContentManagement,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpacingSmall),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMobileQuickLinkCard(
                                title: 'Analytics',
                                icon: Icons.analytics,
                                iconColor: Colors.purple,
                                onTap: _navigateToAnalytics,
                              ),
                            ),
                            // Removed mobile Flashcard Test button - flashcards are now created only through the content page

                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
  
  // Helper method to build mobile-optimized stat cards
  Widget _buildMobileStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to build mobile-optimized quick link cards
  Widget _buildMobileQuickLinkCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to build age breakdown columns
  Widget _buildAgeStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}
